# sre-training

Starting from scratch — teaching myself cloud infrastructure and working toward SRE. Labs, notes, mistakes, and everything I figure out along the way. All real, nothing copied.

I'm Donald Raph. I'm teaching myself cloud infrastructure from the ground up, with the goal of eventually working as an SRE.

I'm not a cloud engineer yet — this repo is how I'm becoming one. Every lab, every broken config, every debugging session will get documented here. I'm not pretending to be further along than I am. I'm just doing the work and writing it down.

## What this repo actually is

This is my training ground. Not a portfolio of finished projects, it's the raw process of learning how production systems work by building and breaking them myself.

- **Labs** — Linux fundamentals, containers, networking, Kubernetes, Terraform, CI/CD. Starting from basics, going deeper each week.
- **Notes** — What I'm studying, what confused me, what finally clicked. Unpolished and honest.
- **Debugging diaries** — When something breaks, I write down the full investigation. What I saw, what I tried that didn't work, and what actually fixed it.
- **Architecture decisions** — When I pick one tool or approach over another, I document why.
- **Diagrams** — If I can't draw how it works, I don't understand it yet.

## Why it's public

I could do all of this in a private repo. But I think there's value in showing the real starting point — not a polished version of the journey, but the actual one. The wrong assumptions, the things that took me 3 hours to figure out, the moments where the docs didn't help and I had to read the source.

If you're starting from a similar place, maybe something here saves you time. If you're further along and see something wrong, I'd appreciate the correction.

## Where I'm headed

```
Now:        Learning cloud fundamentals — Linux, containers, networking, basic IaC
Next:       Kubernetes operations, observability, CI/CD pipelines
Then:       SRE practices — SLOs, incident response, chaos engineering, systems math
Long term:  Open source contribution, technical writing, production SRE work
```

The plan is a 11-month structured playbook covering:
### Foundation (Months 1-2)
- Linux process model, memory management, networking, and troubleshooting
- Docker internals and Kubernetes from the ground up
- Terraform and infrastructure as code
- CI/CD pipelines and GitOps with ArgoCD

### Observability & Reliability (Month 3)
- Prometheus, Grafana, and OpenTelemetry
- SLI/SLO design and error budgets
- Distributed tracing with Jaeger
- Queueing theory, retry storms, and capacity planning

### Resilience Engineering (Months 4-5)
- Chaos engineering with Litmus — GameDays and postmortems
- Incident response — Incident Command, blameless culture, Wheel of Misfortune
- Migration patterns — Strangler Fig, dual-write, zero-downtime database migrations
- IAM, security engineering, and cost optimization

### Advanced Kubernetes & Platform Engineering (Months 6-7)
- Kubernetes advanced — RBAC, NetworkPolicy, StatefulSets, CRDs, HPA
- Platform engineering — internal developer platform, scaffold tooling, software catalog
- Advanced observability — continuous profiling, Thanos, Prometheus exemplars
- Multi-region HA — Terraform multi-AZ, PostgreSQL streaming replication, failover

### Capstone & Career (Months 8-9)
-
-
-

### Specializations (Months 10-11)
- **Event-Driven Architecture** — Kafka on Kubernetes (Strimzi), consumer group patterns,
  Schema Registry, KEDA autoscaling on consumer lag, Saga pattern, event sourcing & CQRS
- **AI Infrastructure & Model Deployment** — GPU node groups on EKS, NVIDIA Device Plugin,
  vLLM for LLM serving, KServe, MLflow model registry, model drift detection, inference SLOs
- **AIOps & AI-Assisted Observability** — anomaly detection on Prometheus metrics (Prophet),
  LLM-powered runbook generation, automated incident correlation, and where AI falls short

## Repo structure

```
sre-training/
├── labs/                   # Hands-on exercises and environments
├── notes/                  # Study notes (rough, for my own reference)
├── debugging-diaries/      # Investigation logs from debugging sessions
├── architecture-decisions/ # ADRs — documenting the "why" behind choices
├── diagrams/               # System and architecture diagrams
├── scripts/                # Tools and automation I build along the way
└── README.md
```

## Current status

Week 1. Starting with Linux process investigation, /proc, memory, containers as processes.

---

## A note on what this is

This is not a tutorial curriculum or a course syllabus. No instructor assigned this to me. I'm not expecting any certificate at the end of this program, just me and the skill i will acquire from it. This is my attempt to close the gap between where i am and where i want to be — deliberately, in public, without shortcuts.

The topics, the depth, the tools — all chosen based on what production SRE work actually looks like, not what looks good on a list. Some weeks will go slower than planned. Some concepts will take longer to stick. But at the end of this, the gap between where I am and where I want to be will be closed🔒

*I will be updating this readme weekly. Starting from zero. Going somewhere.*
