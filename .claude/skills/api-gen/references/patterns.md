# 계층별 코드 패턴

`{Entity}`는 PascalCase, `{entity}`는 kebab/lowercase를 의미한다.

## 1. 타입 정의 (`lib/types/{entity}.ts` 신규 생성)

DTO와 Model을 하나의 파일에 함께 정의한다.

```typescript
// --- DTO (백엔드 snake_case 응답 형태) ---

export interface {Entity}Dto {
    _id: string;
    open: number;
    no: number;
    // ... 엔티티 고유 필드 (snake_case)
    created_at: string;
    updated_at: string;
}

// --- Model (클라이언트 camelCase 형태) ---

export interface {Entity} {
    id: string;
    open: number;
    no: number;
    // ... 엔티티 고유 필드 (camelCase)
    createdAt: string;
    updatedAt: string;
}
```

## 2. Mapper (`lib/mappers/{entity}.ts` 신규 생성)

```typescript
import type { {Entity}Dto, {Entity} } from '@/lib/types/{entity}';

export function map{Entity}(dto: {Entity}Dto): {Entity} {
    return {
        id: dto._id,
        open: dto.open,
        no: dto.no,
        // ... snake_case → camelCase 변환
        createdAt: dto.created_at,
        updatedAt: dto.updated_at,
    };
}
```

주의:
- enum/union 타입은 `as` 캐스팅 사용 (예: `dto.category as Categories`)

## 3. API 함수 (`lib/api/{entity}.ts` 신규 생성)

```typescript
import { apiFetch } from '@/lib/api/client';
import type { ListResponse, PaginationParams, ShowResponse } from '@/lib/types/api';
import type { {Entity}Dto } from '@/lib/types/{entity}';

export function get{Entity}List(params?: PaginationParams) {
    const searchParams = new URLSearchParams();
    if (params?.page !== undefined) searchParams.set('page', String(params.page));
    if (params?.perPage !== undefined) searchParams.set('perPage', String(params.perPage));

    const query = searchParams.toString();
    return apiFetch<ListResponse<{Entity}Dto>>(`/api/{entity}/list${query ? `?${query}` : ''}`);
}

export function get{Entity}ById(id: string) {
    return apiFetch<ShowResponse<{Entity}Dto>>(`/api/{entity}/show/${id}`);
}
```

주의:
- 추가 필터 파라미터가 있으면 `PaginationParams`를 확장하는 커스텀 인터페이스 정의
- API 경로는 백엔드와 확인 필요

## 4. TanStack Query Hook (`lib/hooks/use{Entity}.ts` 신규 생성)

```typescript
import { useQuery } from '@tanstack/react-query';
import { get{Entity}List, get{Entity}ById } from '@/lib/api/{entity}';
import { map{Entity} } from '@/lib/mappers/{entity}';

export const {entity}Keys = {
    all: ['{entity}'] as const,
    list: (params?: ...) => [...{entity}Keys.all, 'list', params] as const,
    detail: (id: string) => [...{entity}Keys.all, 'detail', id] as const,
};

export function use{Entity}List(params?: ...) {
    return useQuery({
        queryKey: {entity}Keys.list(params),
        queryFn: () => get{Entity}List(params),
        select: (data) => ({
            ...data,
            data: data.data.map(map{Entity}),
        }),
    });
}

export function use{Entity}ById(id: string) {
    return useQuery({
        queryKey: {entity}Keys.detail(id),
        queryFn: () => get{Entity}ById(id),
        select: (data) => ({
            ...data,
            data: map{Entity}(data.data),
        }),
        enabled: !!id,
    });
}
```

주의:
- 페이지네이션이 있는 목록은 `placeholderData: keepPreviousData` 추가 고려
- `params`가 있으면 queryKey에 반드시 포함 (캐시 무효화 보장)
- detail 훅은 `enabled: !!id` 필수
