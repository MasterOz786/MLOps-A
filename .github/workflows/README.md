# GitHub Actions Workflows

This directory contains the CI/CD workflows for the Zomato Restaurant Price Prediction application.

## Workflows Overview

### 1. `dev-to-test-workflow.yml`
**Purpose**: Automatically creates/updates pull requests from `dev` to `test` branch when features are pushed to `dev`.

**Triggers**:
- Push to `dev` branch (ignores documentation changes)

**Actions**:
- Creates PR from `dev` to `test` if none exists
- Updates existing PR with new commits
- Runs unit tests on the changes
- Comments on PR with test results

### 2. `unit-tests.yml`
**Purpose**: Runs comprehensive unit tests when PRs are created or updated on the `test` branch.

**Triggers**:
- Pull request to `test` branch
- Push to `test` branch

**Actions**:
- Installs dependencies
- Runs unit tests
- Generates test reports
- Comments on PR with results

### 3. `ci-cd-pipeline.yml`
**Purpose**: Comprehensive CI/CD pipeline for all branches.

**Triggers**:
- Push to any branch (`dev`, `test`, `master`)
- Pull request to `test` or `master`

**Actions**:
- Code quality checks
- Unit tests (multiple Python versions)
- Integration tests
- Security scanning
- Build and package
- Deploy to test environment (if on test branch)

### 4. `auto-pr-dev-to-test.yml`
**Purpose**: Alternative workflow for creating PRs from dev to test.

## Workflow Permissions

The workflows require the following permissions:
- `contents: read` - To checkout code
- `pull-requests: write` - To create/update PRs
- `issues: write` - To comment on PRs
- `actions: read` - To access workflow information

## Required Secrets

No additional secrets are required beyond the default `GITHUB_TOKEN`.

## Branch Protection Rules

Recommended branch protection rules:

### Test Branch
- Require pull request reviews
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Restrict pushes that create files

### Master Branch
- Require pull request reviews (2 reviewers)
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Restrict pushes that create files
- Require linear history

## Usage

1. **Development Workflow**:
   - Make changes in `dev` branch
   - Push to `dev` → Automatically creates PR to `test`
   - Review and merge PR to `test` → Triggers unit tests
   - After tests pass, merge to `master` for production

2. **Testing**:
   - All tests run automatically on PR creation/update
   - Test results are posted as PR comments
   - Failed tests prevent merging

3. **Deployment**:
   - Test branch: Deploys to test environment
   - Master branch: Deploys to production environment

## Monitoring

- Check workflow runs in the "Actions" tab
- Monitor PR comments for test results
- Review build artifacts for deployment packages
