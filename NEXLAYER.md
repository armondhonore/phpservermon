# Nexlayer — phpservermon

<!-- nexlayer:meta version=1 analyzed=2026-06-29T20:42:15Z repo=https://github.com/armondhonore/phpservermon branch=nexlayer -->

> **For AI agents (Claude Code, Cursor, Gemini CLI, Copilot):**
> This file is the **project context** for this Nexlayer deployment — tech stack, env vars, secrets, live URL.
> For full platform detail (nexlayer.yaml schema, Dockerfile rules, CI/CD, task recipes) read **`nexlayer.skills`** in this repo.
>
> **Critical rules (full detail in `nexlayer.skills`):**
> - Inter-pod refs: `${podName:port}` only — never `localhost` or bare hostnames
> - Docker Hub images: prefix with `mirror.gcr.io/library/` — bare tags fail on the cluster
> - Secrets: set in the Nexlayer dashboard — never commit to `nexlayer.yaml` or Dockerfile
>
> **This file:** `agent-managed` sections update automatically. `user-editable` sections (Local Development Setup, Nexlayer Deployment Plan, Build Notes) are yours — preserved across re-analysis.

## Project Summary
<!-- nexlayer:section agent-managed=project_summary -->
phpservermon is a PHP-based server monitoring tool designed to track server health and performance metrics using the Symfony framework.
<!-- nexlayer:end -->

## Technology Stack
<!-- nexlayer:section agent-managed=tech_stack -->
| Name | Kind | Version | Detected From |
|------|------|---------|---------------|
| PHP | language | 7.4 | Dockerfile |
| Apache | infra | 2.4 | Dockerfile |
| Symfony | framework | 3.4 | Dockerfile |
| MySQL | database | Not specified | Dockerfile |
| Composer | tool | Latest | Dockerfile |
<!-- nexlayer:end -->

## Repository Structure
<!-- nexlayer:section agent-managed=structure_map -->
- /var/www/html — Application root (installed via composer create-project)
- docker-entrypoint.sh — Config generation and bootstrap script
- Dockerfile — Container definition for PHP 7.4 + Apache
<!-- nexlayer:end -->

## External Services Required
<!-- nexlayer:section agent-managed=external_deps -->
Services that must be configured separately (not deployed by Nexlayer):

- MySQL Database (Required for data persistence)
<!-- nexlayer:end -->

## Local Development Setup
<!-- nexlayer:section user-editable=local_setup -->
### Prerequisites

- Docker

### Steps

1. `docker build -t phpservermon .` — Build the image from the Dockerfile
2. `docker run -p 80:80 phpservermon` — Run the monitoring server locally

<!-- nexlayer:end -->

## Nexlayer Setup
<!-- nexlayer:section agent-managed=nexlayer_setup -->
### Pod Environment Variables

| Pod | Variable | Value | Kind |
|-----|----------|-------|------|
| `app` | `PSM_DB_HOST` | `"mysql.pod"` | plain |
| `app` | `PSM_DB_PORT` | `"3306"` | plain |
| `app` | `PSM_DB_NAME` | `phpservermon` | plain |
| `app` | `PSM_DB_USER` | `phpservermon` | plain |
| `app` | `PSM_DB_PASS` | _(set via Nexlayer dashboard)_ | secret |
| `mysql` | `MYSQL_DATABASE` | `phpservermon` | plain |
| `mysql` | `MYSQL_USER` | `phpservermon` | plain |
| `mysql` | `MYSQL_PASSWORD` | `"${MYSQL_PASSWORD}"` | inter-pod |
| `mysql` | `MYSQL_ROOT_PASSWORD` | `"${MYSQL_ROOT_PASSWORD}"` | inter-pod |
| `psm-db` | `mountPath` | `/var/lib/mysql` | plain |
| `psm-db` | `size` | `5Gi` | plain |

### Secrets Required

Set these in the Nexlayer dashboard before deploying:

- `PSM_DB_PASS` (`app` pod)

### nexlayer.yaml

```yaml
application:
  name: phpservermon
  pods:
  - name: app
    image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/phpservermon:19f15397a0e"
    path: /
    servicePorts:
    - 80
    vars:
      PSM_DB_HOST: "mysql.pod"
      PSM_DB_PORT: "3306"
      PSM_DB_NAME: phpservermon
      PSM_DB_USER: phpservermon
      PSM_DB_PASS: phpservermon
  - name: mysql
    image: mirror.gcr.io/library/mysql:8.0
    servicePorts:
    - 3306
    vars:
      MYSQL_DATABASE: phpservermon
      MYSQL_USER: phpservermon
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
    volumes:
    - name: psm-db
      mountPath: /var/lib/mysql
      size: 5Gi
```
<!-- nexlayer:end -->

## Nexlayer Deployment Plan
<!-- nexlayer:section user-editable=deployment_plan -->
### Pod Topology

| Pod | Image | Port | Role |
|-----|-------|------|------|
| phpservermon | mirror.gcr.io/library/php:8.2-apache | 80 | web |

### Deployment notes

- The original Dockerfile used a namespaced image (phpservermon/phpservermon) which is prohibited; it has been mapped to a mirrored official PHP image for the pod topology.
- If a database is added in future iterations, it must be placed in a separate pod (e.g., mysql.pod) per Nexlayer rules.

<!-- nexlayer:end -->

## Build Notes
<!-- nexlayer:section user-editable=build_notes -->
<!-- Add notes for future builds here — preserved across re-analysis -->
<!-- nexlayer:end -->

## Nexlayer Configuration
<!-- nexlayer:section agent-managed=nexlayer_config -->
**Last deployed:** 2026-06-29T21:13:22Z  
**Live URL:** https://relaxed-weasel-phpservermon.cloud.nexlayer.ai  
**Runtime:**  · **Port:** auto-detected  
**Deploy branch:** nexlayer  

```yaml
application:
  name: phpservermon
  pods:
  - name: app
    image: "registry.nexlayer.io/user_01kece1xyh817dwff7wnarhkxd/phpservermon:19f15397a0e"
    path: /
    servicePorts:
    - 80
    vars:
      PSM_DB_HOST: "mysql.pod"
      PSM_DB_PORT: "3306"
      PSM_DB_NAME: phpservermon
      PSM_DB_USER: phpservermon
      PSM_DB_PASS: phpservermon
  - name: mysql
    image: mirror.gcr.io/library/mysql:8.0
    servicePorts:
    - 3306
    vars:
      MYSQL_DATABASE: phpservermon
      MYSQL_USER: phpservermon
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
    volumes:
    - name: psm-db
      mountPath: /var/lib/mysql
      size: 5Gi
```
<!-- nexlayer:end -->

## Build History
<!-- nexlayer:section agent-managed=build_history -->
| Date | Status | Notes |
|------|--------|-------|
| 2026-06-29T21:12:15Z | analyzed | initial repo analysis |
| 2026-06-29T21:13:22Z | success | deployed https://relaxed-weasel-phpservermon.cloud.nexlayer.ai |
<!-- nexlayer:end -->





