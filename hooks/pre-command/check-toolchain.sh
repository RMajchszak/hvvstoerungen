#!/bin/bash
# Pre-command hook: Validate toolchain is properly detected
# Exit codes: 0=proceed, 1=warn, 2=abort

set -e

# Detect project type
detect_toolchain() {
    if [ -f "package.json" ]; then
        echo "javascript"
    elif [ -f "tsconfig.json" ]; then
        echo "typescript"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "Gemfile" ]; then
        echo "ruby"
    else
        echo "generic"
    fi
}

# Check if required tools exist
check_tools() {
    local toolchain=$1

    case "$toolchain" in
        javascript|typescript)
            if ! command -v node &> /dev/null; then
                echo "Warning: Node.js not found" >&2
                return 1
            fi
            ;;
        python)
            if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
                echo "Warning: Python not found" >&2
                return 1
            fi
            ;;
        rust)
            if ! command -v cargo &> /dev/null; then
                echo "Warning: Cargo not found" >&2
                return 1
            fi
            ;;
        go)
            if ! command -v go &> /dev/null; then
                echo "Warning: Go not found" >&2
                return 1
            fi
            ;;
    esac

    return 0
}

# Detect available infrastructure tools
detect_infrastructure() {
    local infra_tools=()

    # Cloud CLIs
    [ -d ".azure" ] || [ -f "azure-pipelines.yml" ] && command -v az &>/dev/null && infra_tools+=("az")
    [ -d ".aws" ] || [ -f "samconfig.toml" ] && command -v aws &>/dev/null && infra_tools+=("aws")
    [ -f "app.yaml" ] || [ -f "cloudbuild.yaml" ] && command -v gcloud &>/dev/null && infra_tools+=("gcloud")

    # Git platforms
    [ -d ".github" ] && command -v gh &>/dev/null && infra_tools+=("gh")
    [ -f ".gitlab-ci.yml" ] && command -v glab &>/dev/null && infra_tools+=("glab")

    # Kubernetes
    [ -d "k8s" ] || [ -d "kubernetes" ] || [ -f "kustomization.yaml" ] && command -v kubectl &>/dev/null && infra_tools+=("kubectl")
    [ -f "Chart.yaml" ] || [ -d "charts" ] && command -v helm &>/dev/null && infra_tools+=("helm")

    # IaC
    find . -maxdepth 2 -name "*.tf" -print -quit 2>/dev/null | grep -q . && command -v terraform &>/dev/null && infra_tools+=("terraform")
    [ -f "Pulumi.yaml" ] && command -v pulumi &>/dev/null && infra_tools+=("pulumi")

    # Containers
    [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "compose.yaml" ] && command -v docker &>/dev/null && infra_tools+=("docker")

    # Output as JSON array
    if [ ${#infra_tools[@]} -gt 0 ]; then
        printf '%s\n' "${infra_tools[@]}" | jq -R . | jq -s .
    else
        echo "[]"
    fi
}

# Main
TOOLCHAIN=$(detect_toolchain)
INFRA_TOOLS=$(detect_infrastructure)

# Output combined detection as JSON
echo "{\"toolchain\": \"$TOOLCHAIN\", \"infrastructure\": $INFRA_TOOLS}"

if check_tools "$TOOLCHAIN"; then
    exit 0
else
    exit 1  # Warn but proceed
fi
