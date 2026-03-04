AWS ALB + Argo Rollouts (most common)

Production Canary Architecture (EKS)
Users
   │
   ▼
AWS ALB
   │
   ▼
Kubernetes Service
   │
   ▼
Argo Rollouts Controller
   │
   ├── Stable ReplicaSet (blue)
   └── Canary ReplicaSet (green)

Traffic is gradually shifted

100/0
90/10
75/25
50/50
0/100

Install agro rollouts
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

Install Kubectl plugins:

curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64

chmod +x kubectl-argo-rollouts-linux-amd64
mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

kubectl apply -f blue-app.yaml

kubectl apply -f services.yaml

kubectl apply -f ingress.yaml

Check the url to verify the app

Change the image name : image: adamtravis/rollouts:green

kubectl apply -f rollout.yaml

Watch Canary Rollout:
kubectl argo rollouts get rollout canary-demo -n foo

Production Based Flow
CI/CD Pipeline
      │
      ▼
Deploy new image
      │
      ▼
Argo Rollouts starts Canary
      │
      ▼
Prometheus / Datadog checks metrics
      │
      ▼
Success → promote
Failure → rollback


DashBoard the agro rollout:

ssh -L 3100:localhost:3100 arjunckm@4.186.27.137
kubectl argo rollouts dashboard -n foo

Installing the Monitoring Tool:
1. Install Helm
2. helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
3. helm repo update
4. helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
5. kubectl get pods -n monitoring
6. kubectl port-forward svc/monitoring-grafana -n monitoring 3000:80 --address 0.0.0.0


How to set the Alerting in grafana:

For kube-prometheus-stack, node CPU usage per node (percentage) is typically:
100 - (
  avg by (instance) (
    rate(node_cpu_seconds_total{mode="idle"}[5m])
  ) * 100
)
This gives CPU usage % per node over 5 minutes.

For node memory usage:

text
(1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100
That gives memory usage % per node.
​

2. Create alert rule in Grafana (new alerting)
In Grafana UI (v9+/kube-prometheus-stack defaults):

Go to Alerting → Alert rules → New alert rule.

Rule name: e.g., Node CPU > 90% for 5m.

Query:

Data source: your Prometheus (from kube-prometheus-stack, usually named Prometheus or similar).

Query A: paste the CPU PromQL above.

Click Run queries to verify you see time series per instance.

Condition:

Choose Reduce (e.g., last() or avg() over each series).

Then Classic condition: A > 90.

Set For (Evaluate for) to 5m so it must stay above 90% for 5 minutes.
​

Evaluate every: e.g., 1m.

Labels: add severity="warning" or severity="critical" as you like.

Notification policy:

Under Contact points, configure email/Slack/Teams, etc.

Ensure the alert rule is attached to a notification policy so alerts are actually delivered.
​

Repeat the same flow with the memory query for a memory alert (e.g., > 90 for 5m).

3. Quick sanity checks
Before finalizing:

In Prometheus (port-forward monitoring-prometheus-...:9090), test the PromQL and confirm it returns values between 0–100 for each instance.
​

In Grafana, add a time series panel with the same query to visually confirm that when a node is under load, the line crosses 90%.

If you share which specific metric names you see in Prometheus (node_cpu_seconds_total vs container_cpu_usage_seconds_total), I can tailor an exact rule for node vs pod alerts.

Follow-ups

What PromQL query monitors node memory usage at max

How to configure Alertmanager notifications for Grafana alerts

Best practices for alert thresholds on Kubernetes nodes

How to set alerts for pod CPU usage exceeding limits

Import Node Exporter dashboard with built-in alerts in Grafana

Free preview limit reached. Now using basic search.
