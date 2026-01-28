# Oracle APEX Session Context Inspector

A lightweight Oracle APEX utility that helps developers inspect and debug the current session context in real time. The repository delivers a single APEX page backed by a small PL/SQL package so you can see the most relevant session, environment, and security values without adding dashboard-style UI or external dependencies.

## Why it’s useful

When troubleshooting APEX applications, it is helpful to quickly see the exact session context (user, app, security schemes, environment values) that APEX is using. This tool provides a focused, production-ready reference view so you can validate assumptions and debug authorization, localization, and client context issues.

## Features

- One-page APEX view of session context values.
- Session & application details (APP_ID, APP_USER, session ID, workspace, authentication scheme).
- Environment details (session language, timezone, database user, database name, APEX version).
- Security & authorization checks (authorization schemes evaluated YES/NO, build options, authentication state).
- Client context (browser user agent, mobile session detection).
- No external libraries; works with Oracle APEX 21+.

## Repository layout

```
/ sql
  install.sql
  uninstall.sql
/ apex
  apex_page_export.sql
README.md
CHANGELOG.md
```

## Installation

1. Connect to the target schema where the APEX application runs.
2. Run the installation script:

   ```sql
   @sql/install.sql
   ```

3. Create the APEX page using the instructions in `apex/apex_page_export.sql` (or replace that file with a real export if you can capture one).

## How to use

1. Log into the APEX app that includes the Session Context Inspector page.
2. Navigate to the page.
3. Review the session context table to validate session, environment, security, and client details.

## Supported APEX versions

- Oracle APEX 21.1 and higher.

## Intended audience

- Oracle APEX developers
- Oracle ACE community members

## Uninstall

Run the uninstall script:

```sql
@sql/uninstall.sql
```
