# Monitoring Project Movie

Prometheus and Alertmanager configuration to monitor a movie application stack with node metrics, database metrics, and HTTP blackbox probes, plus Telegram alerts.

## What is monitored

- `node_exporter` on port 9100 (host metrics)
- `database_exporter` on port 9104 (database metrics)
- `blackbox_exporter` on port 9115 probing:
  - http://134.209.126.127:3000
  - http://134.209.126.127:8088

## Alerting

- High RAM usage: triggers when RAM usage is > 50% for 5 seconds.
- Alerts are routed to Telegram via Alertmanager.

## Files

- [prometheus.yml](prometheus.yml): Prometheus scrape configs and Alertmanager target.
- [rules/alert-rules.yml](rules/alert-rules.yml): Prometheus alert rules.
- [rules/alertmanager.yml](rules/alertmanager.yml): Alertmanager routing and Telegram receiver.

## Configuration notes

- Update the target host and ports in [prometheus.yml](prometheus.yml) to match your environment.
- The alert rules file path in [prometheus.yml](prometheus.yml) is set to `/etc/prometheus/alert-rules.yml`. If you run Prometheus locally, either:
  - mount rules/alert-rules.yml to `/etc/prometheus/alert-rules.yml`, or
  - change the path to point to this repository file.
- [rules/alertmanager.yml](rules/alertmanager.yml) expects these environment variables:
  - `TELEGRAM_TOKEN`
  - `TELEGRAM_BOT_ID`

## Minimal run checklist

1. Start exporters:
   - `node_exporter` on port 9100
   - database exporter on port 9104
   - `blackbox_exporter` on port 9115
2. Start Alertmanager with [rules/alertmanager.yml](rules/alertmanager.yml).
3. Start Prometheus with [prometheus.yml](prometheus.yml).
4. Verify targets in Prometheus UI and watch for alert delivery in Telegram.
