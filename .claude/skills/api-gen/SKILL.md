---
name: api-gen
description: 4계층 API 보일러플레이트(Types → Mappers → API → Hooks)를 생성하는 스킬. 새로운 API 엔티티 추가, API 연동 코드 생성, DTO/Model 타입 정의, TanStack Query 훅 작성이 필요할 때 사용. "API 추가", "API 연동", "api-gen", "엔티티 추가", "훅 만들어줘" 등의 요청에 트리거.
---

# API 계층 코드 생성

프로젝트의 4계층 API 아키텍처에 맞는 보일러플레이트를 생성한다.

## 데이터 흐름

```
API Response (DTO) → apiFetch() → useQuery() → select(mapper) → Model
```

## 중요 규칙

- **Barrel import 금지**: `index.ts`를 통한 barrel export/import를 사용하지 않는다. 각 파일에서 직접 import.
  - Bad: `import type { TicketModel } from '@/lib/types'`
  - Good: `import type { TicketModel } from '@/lib/types/ticket'`
- 엔티티별로 `lib/types/{entity}.ts` 파일을 생성하여 DTO와 Model을 함께 정의한다.
- 기존 패턴의 import 경로와 네이밍 컨벤션을 반드시 따른다.

## 생성 워크플로우

### 1단계: 입력 확인

사용자에게 아래 정보를 확인:
- 엔티티 이름 (예: ticket, review)
- 백엔드 DTO 스키마 또는 예시 JSON 응답 (OpenAPI 스펙 파일이 있으면 파싱)

### 2단계: 기존 코드 확인

생성 전에 반드시 읽어야 할 파일:
- `lib/types/api.ts` - `ListResponse`, `ShowResponse` 등 공통 타입 확인
- `lib/types/` 디렉토리 내 기존 타입 파일들 - 네이밍 패턴 확인

### 3단계: 4개 계층 생성

각 계층의 구체적 패턴은 [references/patterns.md](references/patterns.md) 참고.

**계층 요약:**

| 계층 | 위치 | 역할 |
|------|------|------|
| 타입 (DTO + Model) | `lib/types/{entity}.ts` 신규 | DTO(snake_case) + Model(camelCase) 함께 정의 |
| Mapper | `lib/mappers/{entity}.ts` 신규 | DTO → Model 변환 |
| API 함수 | `lib/api/{entity}.ts` 신규 | `apiFetch` 래퍼 |
| Query Hook | `lib/hooks/use{Entity}.ts` 신규 | TanStack Query + select 매핑 |

### 4단계: 검증

- TypeScript 타입 에러 없는지 확인
- import 경로가 기존 패턴과 일치하는지 확인
