# OpenCode Harness

재현 가능한 OpenCode 에이전트 생태계 — 한 줄로 동일 환경 재구축.

```bash
git clone <this-repo> && cd opencode-harness && ./install.sh
```

## 구성

```
opencode-harness/
├── install.sh          # 전체 설치 스크립트
├── opencode.json       # 에이전트 설정 (15 inline + MCP + 권한)
├── AGENTS.md           # 글로벌 에이전트 지시사항 (2-Tier 라우팅)
├── prompts/
│   ├── build.md        # Build 에이전트 프롬프트 (도메인 라우팅 + 품질 파이프라인)
│   └── plan.md         # Plan 에이전트 프롬프트 (전략 코디네이터)
└── plugins/
    └── lean-ctx.ts     # lean-ctx 통합 플러그인
```

## 아키텍처

```
Tier 1 — Workflow Agents (12)
├── Plan (primary)     → 전략 분석, 작업 분해, 전문가 지정
├── Build (primary)    → 구현 + 서브에이전트 오케스트레이션
├── Reviewer (primary) → 코드 리뷰 + 품질 게이트
├── scout, research, tester, refactor, debug,
│   devops, security, docs, migrate, perf, api, data

Tier 2 — Domain Specialists (184)
├── Engineering (30)   → Frontend, Backend, Database, Security, ...
├── Testing (8)        → API Tester, Accessibility Auditor, ...
├── Design (5)         → UI Designer, UX Architect, ...
└── Strategy (3)       → Agents Orchestrator, Product Manager, ...
```

## 품질 파이프라인

모든 구현 후 자동으로 실행:

```
Phase 1: @Code Reviewer + @Security Engineer + @tester (병렬)
Phase 2: @docs + @perf (Phase 1 통과 후)
```

## 필수 사전 준비

| 항목 | 설치 방법 |
|------|----------|
| Node.js >= 22 | `nvm install 22` |
| OpenCode CLI | `npm install -g opencode@latest` |
| DeepSeek API 키 | `opencode providers login` |

## MCP 서버 (수동 설치 필요)

| 서버 | 설치 |
|------|------|
| lean-ctx | `curl -fsSL https://raw.githubusercontent.com/yvgude/lean-ctx/main/install.sh \| bash` |
| codegraph | `npm install -g @codegraph/cli` |
| agentmemory | `npx` 자동 설치 |
| chrome-devtools | `npx` 자동 설치 |
| playwright | `npx` 자동 설치 |
| maru-deep-pro-search | 커스텀 빌드 |
| open-design | open-design.ai 에서 다운로드 |

## 재설치/다른 컴퓨터

```bash
# 1. 하네스 클론
git clone <repo-url> opencode-harness && cd opencode-harness

# 2. 실행
./install.sh

# 3. API 키 설정
opencode providers login

# 4. OpenCode 재시작
# quit → opencode
```
