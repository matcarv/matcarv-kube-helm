#!/bin/bash

# Helm Deployment Script for matcarv-kube-helm
# Usage: ./deploy.sh [command] [release-name]

set -e

CHART_PATH="."
RELEASE_NAME=${2:-"my-app"}
VALUES_FILE="values.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_usage() {
    echo "Usage: $0 [command] [release-name]"
    echo ""
    echo "Commands:"
    echo "  install     - Install the Helm chart"
    echo "  upgrade     - Upgrade existing release"
    echo "  uninstall   - Uninstall the release"
    echo "  template    - Generate templates without installing"
    echo "  status      - Show release status"
    echo "  rollback    - Rollback to previous version"
    echo "  lint        - Lint the chart"
    echo "  test        - Test the release"
    echo ""
    echo "Examples:"
    echo "  $0 install my-app"
    echo "  $0 upgrade my-app"
    echo "  $0 template my-app"
}

check_requirements() {
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}Error: Helm is not installed${NC}"
        exit 1
    fi
    
    if [[ ! -f "Chart.yaml" ]]; then
        echo -e "${RED}Error: Chart.yaml not found. Run from chart directory${NC}"
        exit 1
    fi
    
    if [[ ! -f "$VALUES_FILE" ]]; then
        echo -e "${RED}Error: $VALUES_FILE not found${NC}"
        exit 1
    fi
}

install_chart() {
    echo -e "${GREEN}Installing Helm chart...${NC}"
    helm install "$RELEASE_NAME" "$CHART_PATH" -f "$VALUES_FILE"
    echo -e "${GREEN}Installation completed!${NC}"
}

upgrade_chart() {
    echo -e "${GREEN}Upgrading Helm chart...${NC}"
    helm upgrade "$RELEASE_NAME" "$CHART_PATH" -f "$VALUES_FILE"
    echo -e "${GREEN}Upgrade completed!${NC}"
}

uninstall_chart() {
    echo -e "${YELLOW}Uninstalling Helm chart...${NC}"
    helm uninstall "$RELEASE_NAME"
    echo -e "${GREEN}Uninstallation completed!${NC}"
}

template_chart() {
    echo -e "${GREEN}Generating templates...${NC}"
    helm template "$RELEASE_NAME" "$CHART_PATH" -f "$VALUES_FILE"
}

status_chart() {
    echo -e "${GREEN}Checking release status...${NC}"
    helm status "$RELEASE_NAME"
}

rollback_chart() {
    echo -e "${YELLOW}Rolling back release...${NC}"
    helm rollback "$RELEASE_NAME"
    echo -e "${GREEN}Rollback completed!${NC}"
}

lint_chart() {
    echo -e "${GREEN}Linting chart...${NC}"
    helm lint "$CHART_PATH"
    echo -e "${GREEN}Lint completed!${NC}"
}

test_chart() {
    echo -e "${GREEN}Testing release...${NC}"
    helm test "$RELEASE_NAME"
    echo -e "${GREEN}Test completed!${NC}"
}

# Main script
check_requirements

case ${1:-""} in
    install)
        install_chart
        ;;
    upgrade)
        upgrade_chart
        ;;
    uninstall)
        uninstall_chart
        ;;
    template)
        template_chart
        ;;
    status)
        status_chart
        ;;
    rollback)
        rollback_chart
        ;;
    lint)
        lint_chart
        ;;
    test)
        test_chart
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
