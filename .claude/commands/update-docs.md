---
description: Analyze codebase and update documentation in /docs folder
allowed-tools: Read, Glob, Grep, Edit, Write, Task, Bash
---

# Update Documentation Command

Analyze the current project's codebase and update documentation files in the `/docs` folder to reflect the latest state.

## Arguments

$ARGUMENTS

- No arguments: Update all documentation files in `/docs`
- Specific filename: Update only the specified file (e.g., `ONBOARDING.md`, `README.md`)

## Execution Steps

### Step 1: Discover Project Structure

1. **Identify project type** by checking for:
    - `package.json` → Node.js/JavaScript project
    - `tsconfig.json` → TypeScript project
    - `next.config.*` → Next.js project
    - `vite.config.*` → Vite project
    - `pyproject.toml` / `requirements.txt` → Python project
    - `go.mod` → Go project
    - `Cargo.toml` → Rust project
    - `pom.xml` / `build.gradle` → Java project

2. **Scan directory structure**:

    ```
    Glob patterns to use:
    - **/*/           → Top-level directories
    - src/**/*        → Source files
    - app/**/*        → App directory (Next.js App Router)
    - pages/**/*      → Pages directory (Next.js Pages Router)
    - components/**/* → Component files
    - lib/**/*        → Library/utility files
    - server/**/*     → Server-side code
    - api/**/*        → API layer
    - tests/**/*      → Test files
    ```

3. **Extract metadata**:
    - Read `package.json` for dependencies and versions
    - Read config files for framework settings
    - Identify entry points and main modules

### Step 2: Discover Existing Documentation

1. **Find all docs**:

    ```
    Glob: docs/**/*.md
    Glob: docs/**/*.mdx
    Glob: *.md (root level: README.md, CONTRIBUTING.md, etc.)
    ```

2. **Categorize documentation types**:
    - **Onboarding docs**: Files containing setup/getting started info
    - **Architecture docs**: Files with diagrams, system design
    - **API docs**: Endpoint documentation
    - **Route/Page docs**: Page/route mapping
    - **Changelog**: Version history
    - **Checklist/TODO**: Task tracking documents

### Step 3: Analyze and Compare

For each documentation file found:

1. **Read current content**
2. **Identify sections that reference code**:
    - Directory trees / project structure
    - File references and paths
    - Dependency versions
    - API endpoints
    - Component lists
    - Configuration examples
3. **Compare with actual codebase**:
    - Find outdated paths/files
    - Detect missing new files/features
    - Check version mismatches
    - Identify removed items still documented

### Step 4: Update Documentation

Apply updates using the Edit tool:

1. **Project structure sections**:
    - Regenerate directory trees
    - Add new directories/files
    - Remove deleted items

2. **Version information**:
    - Update dependency versions from package.json/config files
    - Update framework versions

3. **Code references**:
    - Update file paths
    - Add new components/modules
    - Remove deprecated items

4. **Diagrams (Mermaid/PlantUML)**:
    - Update architecture diagrams if structure changed
    - Verify diagram syntax is valid

5. **Metadata**:
    - Update "Last modified" date to today
    - Update version numbers if applicable

### Step 5: Report Changes

After updating, provide a summary:

```
## Documentation Update Summary

### Files Updated:
- docs/ONBOARDING.md
  - Updated: Project structure tree
  - Added: New component section
  - Removed: Deprecated API endpoints

### Files Skipped (no changes needed):
- docs/CONTRIBUTING.md

### Items Requiring Manual Review:
- docs/ARCHITECTURE.md: Complex diagram may need manual verification
```

## Guidelines

1. **Preserve existing style**: Match the formatting, language, and conventions of each document
2. **Be conservative**: Only update sections that reference actual code/config
3. **Don't invent**: Never add information you can't verify from the codebase
4. **Mark uncertainties**: If something is unclear, note it for manual review
5. **Maintain language**: Keep documents in their original language (Korean, English, etc.)
6. **Validate syntax**: Ensure Mermaid/diagram code blocks remain valid after edits
7. **Preserve checkboxes**: In checklist docs, only update `[x]`/`[ ]` if you can verify implementation status

## Examples

```bash
/update-docs                    # Update all docs in /docs folder
/update-docs ONBOARDING.md      # Update only ONBOARDING.md
/update-docs architecture       # Update docs matching "architecture" in filename
```
