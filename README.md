# Ganda-It

> 간다 간다 파일 간다잇-!

Training-only vulnerable Managed File Transfer lab. The application stack is simplified to Linux + nginx + PHP-FPM + MySQL, while the attack and logging flow is inspired by the 2023 MOVEit incident.

## Logging layers

- `logs/nginx/access.log`: raw HTTP requests, status, user-agent, request ID, request time.
- `logs/nginx/error.log`: nginx errors.
- `logs/mft/DMZ_WEB.log`: authentication, guest-link, session-facing application events.
- `logs/mft/DMZ_ISAPI.log`: package import and normal file download events.
- `logs/mft/syslog-mft.log`: local syslog copy of product events.
- MySQL `audit_logs`: normal product audit events.
- MySQL binary log: row-level database changes for recovery/DFIR. `general_log` remains OFF by design.

## Important forensic design choice

`human2.php` intentionally performs direct DB operations and does **not** call `audit_event()`. Therefore a backdoor-created account such as `svc_backup` can exist in `users` without a corresponding `USER_CREATE` product audit event. The HTTP call is still visible in nginx logs and the row change can be present in binlog.

## Start

If this is an upgrade from the first build, recreate the DB once so `audit_logs` exists:

```bash
docker compose down -v
docker compose up --build -d
```

Open: `http://localhost`

Demo user:

| ID | PW | Description |
| --- | --- | --- |
| `admin` | `1234` | Admin Privilage |
| `alice` | `1234` | Test Account |
| `deployer` | `1234` | Vendor Employee |
| `hospital` | `1234` | Hospital IT Manager |

## Useful log commands

```bash
tail -f /opt/ganda-it-service/logs/nginx/access.log
tail -f /opt/ganda-it-service/logs/mft/DMZ_WEB.log
tail -f /opt/ganda-it-service/logs/mft/DMZ_ISAPI.log
tail -f /opt/ganda-it-service/logs/mft/syslog-mft.log
```

Audit DB:

```bash
docker compose exec db mysql -umft -pmftpass mft -e "SELECT event_time,username,event_type,target,remote_ip,success FROM audit_logs ORDER BY id;"
```

Binary logs:

```bash
docker compose exec db mysql -uroot -prootpass -e "SHOW BINARY LOGS;"
```

## Expected attack evidence

1. SQLi against `/guest.php` → nginx + `DMZ_WEB.log`.
2. Hijacked admin session used against `/admin/` → nginx.
3. `human2.php` import → nginx + `DMZ_ISAPI.log` + audit DB.
4. `/uploads/human2.php?action=...` → nginx.
5. Direct backdoor DB changes → MySQL binlog, but no normal product `USER_CREATE` audit record.
6. Subsequent `svc_backup` login → nginx + `DMZ_WEB.log` + audit DB.

This mismatch is deliberate and useful during timeline reconstruction.
