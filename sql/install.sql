prompt Installing APEX Session Context Inspector

create or replace package apex_session_ctx_pkg as
  type t_context_row is record (
    category varchar2(50),
    name     varchar2(200),
    value    varchar2(4000)
  );

  type t_context_tab is table of t_context_row;

  function get_context return t_context_tab pipelined;
end apex_session_ctx_pkg;
/

create or replace package body apex_session_ctx_pkg as
  function yes_no(p_value boolean) return varchar2 is
  begin
    if p_value then
      return 'YES';
    end if;

    return 'NO';
  exception
    when others then
      return 'NO';
  end yes_no;

  function get_app_name(p_app_id number) return varchar2 is
    v_name apex_applications.application_name%type;
  begin
    select application_name
      into v_name
      from apex_applications
     where application_id = p_app_id;

    return v_name;
  exception
    when no_data_found then
      return null;
    when others then
      return null;
  end get_app_name;

  function get_auth_scheme_name(p_app_id number) return varchar2 is
    v_name apex_applications.authentication_scheme%type;
  begin
    select authentication_scheme
      into v_name
      from apex_applications
     where application_id = p_app_id;

    return v_name;
  exception
    when no_data_found then
      return null;
    when others then
      return null;
  end get_auth_scheme_name;

  function get_workspace_name return varchar2 is
  begin
    return apex_util.find_security_group_name(apex_application.g_security_group_id);
  exception
    when others then
      return null;
  end get_workspace_name;

  function get_apex_version return varchar2 is
    v_version apex_release.version_no%type;
  begin
    select version_no
      into v_version
      from apex_release;

    return v_version;
  exception
    when others then
      return null;
  end get_apex_version;

  function get_database_name return varchar2 is
    v_name varchar2(128);
  begin
    v_name := sys_context('USERENV', 'DB_NAME');

    if v_name is null then
      begin
        select name
          into v_name
          from v$database;
      exception
        when others then
          v_name := null;
      end;
    end if;

    return v_name;
  exception
    when others then
      return null;
  end get_database_name;

  function is_authenticated return varchar2 is
  begin
    return yes_no(apex_authentication.is_authenticated);
  exception
    when others then
      return 'NO';
  end is_authenticated;

  function is_mobile return varchar2 is
  begin
    return yes_no(apex_util.is_session_mobile);
  exception
    when others then
      return 'NO';
  end is_mobile;

  function get_user_agent return varchar2 is
  begin
    return owa_util.get_cgi_env('HTTP_USER_AGENT');
  exception
    when others then
      return null;
  end get_user_agent;

  function get_context return t_context_tab pipelined is
    v_app_id         number := apex_application.g_flow_id;
    v_page_id        number := apex_application.g_flow_step_id;
    v_session_id     number := apex_application.g_instance;
    v_app_user       varchar2(4000) := apex_application.g_user;
  begin
    pipe row (t_context_row('Session & Application', 'APP_ID', to_char(v_app_id)));
    pipe row (t_context_row('Session & Application', 'APP_NAME', get_app_name(v_app_id)));
    pipe row (t_context_row('Session & Application', 'APP_PAGE_ID', to_char(v_page_id)));
    pipe row (t_context_row('Session & Application', 'APP_USER', v_app_user));
    pipe row (t_context_row('Session & Application', 'SESSION_ID', to_char(v_session_id)));
    pipe row (t_context_row('Session & Application', 'WORKSPACE', get_workspace_name));
    pipe row (t_context_row('Session & Application', 'AUTHENTICATION_SCHEME', get_auth_scheme_name(v_app_id)));

    pipe row (t_context_row('Environment', 'SESSION_LANGUAGE', sys_context('USERENV', 'LANGUAGE')));
    pipe row (t_context_row('Environment', 'SESSION_TIMEZONE', sys_context('USERENV', 'SESSION_TIMEZONE')));
    pipe row (t_context_row('Environment', 'DATABASE_USER', sys_context('USERENV', 'CURRENT_USER')));
    pipe row (t_context_row('Environment', 'DATABASE_NAME', get_database_name));
    pipe row (t_context_row('Environment', 'APEX_VERSION', get_apex_version));

    pipe row (t_context_row('Security & Authorization', 'IS_AUTHENTICATED', is_authenticated));

    for auth_row in (
      select authorization_name
        from apex_application_authorization
       where application_id = v_app_id
       order by authorization_name
    ) loop
      pipe row (
        t_context_row(
          'Security & Authorization',
          'AUTHORIZATION: ' || auth_row.authorization_name,
          yes_no(apex_authorization.is_authorized(p_authorization_name => auth_row.authorization_name))
        )
      );
    end loop;

    for build_row in (
      select build_option_name,
             status
        from apex_application_build_options
       where application_id = v_app_id
       order by build_option_name
    ) loop
      pipe row (
        t_context_row(
          'Security & Authorization',
          'BUILD_OPTION: ' || build_row.build_option_name,
          build_row.status
        )
      );
    end loop;

    pipe row (t_context_row('Client Context', 'BROWSER_USER_AGENT', get_user_agent));
    pipe row (t_context_row('Client Context', 'IS_MOBILE', is_mobile));

    return;
  exception
    when others then
      pipe row (t_context_row('System', 'ERROR', sqlerrm));
      return;
  end get_context;
end apex_session_ctx_pkg;
/

prompt Installation complete
