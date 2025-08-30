# matcarv-kube-helm

Helm chart para deploy de aplicações Kubernetes com templates YAML otimizados e configurações de segurança.

## Estrutura do Projeto

### Arquivos de Configuração Principal

#### `Chart.yaml`
Arquivo de metadados do Helm chart contendo:
- Nome do projeto: `your-project-helm`
- Versão do chart: `1.0.0`
- Versão da aplicação: `1.0.0`
- Tipo: `application`
- Descrição do projeto

#### `values.yaml`
Arquivo de configuração principal com valores padrão:
- **Configurações de deployment**: réplicas, imagem Docker, políticas de pull
- **Configurações de serviço**: tipo ClusterIP, portas e protocolos
- **Configurações de ingress**: habilitado por padrão com host `eks.medwise.com.br`
- **Recursos computacionais**: limits e requests de CPU/memória
- **Variáveis de ambiente**: configurações de banco de dados
- **HPA**: auto-scaling habilitado com máximo de 2 réplicas
- **Resource Quota**: limites de recursos do namespace
- **RBAC**: controle de acesso desabilitado por padrão

### Templates Kubernetes

#### `templates/namespace.yaml`
Namespace dedicado para a aplicação:
- Nome baseado no release name
- Labels padronizados para identificação

#### `templates/deployment.yaml`
Deployment principal da aplicação com:
- Configuração de pods e containers
- Integração com ConfigMap e Secret via `envFrom`
- Definição de recursos e health checks
- Configuração de imagem e políticas de pull
- Security contexts configurados
- Probes de liveness e readiness

#### `templates/configmap.yaml`
ConfigMap para variáveis não sensíveis:
- `DATABASE_URL`: URL de conexão com o banco
- `DATABASE_USERNAME`: usuário do banco de dados
- Namespace dinâmico baseado no release name

#### `templates/secret.yaml`
Secret para dados sensíveis:
- `DATABASE_PASSWORD`: senha do banco de forma criptografada
- Tipo `Opaque` para máxima segurança
- Namespace dinâmico baseado no release name

#### `templates/service.yaml`
Service para exposição interna:
- Tipo ClusterIP para comunicação interna
- Mapeamento de portas 80 → 8080
- Seletor baseado em labels do deployment

#### `templates/ingress.yaml`
Ingress para exposição externa:
- Configuração condicional baseada em `ingress.enabled`
- Host configurável via values
- Roteamento para o service interno
- Suporte a TLS e annotations customizadas

#### `templates/serviceaccount.yaml`
ServiceAccount para identidade dos pods:
- Conta de serviço dedicada para a aplicação
- Integração com RBAC quando habilitado

#### `templates/role.yaml`
Role para permissões RBAC:
- Configuração condicional via `rbac.enabled`
- Permissões otimizadas sem duplicidade
- Escopo limitado ao namespace

#### `templates/rolebinding.yaml`
RoleBinding para conectar Role ao ServiceAccount:
- Vincula o Role ao ServiceAccount
- Necessário para RBAC funcionar

#### `templates/hpa.yaml`
Horizontal Pod Autoscaler:
- Auto-scaling baseado em CPU (90% por padrão)
- Configuração condicional via `hpa.enabled`
- Escala entre 1 e 2 réplicas por padrão
- Usa API autoscaling/v2

#### `templates/quota.yaml`
ResourceQuota para controle de recursos:
- Limites de CPU e memória por namespace
- Prevenção de consumo excessivo de recursos
- Configuração via values.yaml

## Configuração Obrigatória

### Valores que DEVEM ser preenchidos no `values.yaml`:

#### **Imagem Docker (OBRIGATÓRIO)**
```yaml
image:
  repository: YOUR_IMAGE_REPO           # Substitua pelos dados reais
  tag: YOUR_IMAGE_TAG                   # Versão da sua aplicação
```

#### **Banco de Dados (OBRIGATÓRIO)**
```yaml
env:
  database:
    url: YOUR_DATABASE_URL              # URL real do banco
    username: YOUR_DATABASE_USERNAME    # Usuário do banco
    password: YOUR_DATABASE_PASSWORD    # Senha do banco
```

#### **Ingress Host (OBRIGATÓRIO)**
```yaml
ingress:
  host: "sua-aplicacao.dominio.com"  # Domínio real da aplicação
```

### Valores Opcionais Recomendados:

#### **Recursos Computacionais**
```yaml
resources:
  limits:
    cpu: 500m       # Ajuste conforme necessário
    memory: 1Gi   # Ajuste conforme necessário
  requests:
    cpu: 200m       # Ajuste conforme necessário
    memory: 512Gi     # Ajuste conforme necessário
```

#### **Auto-scaling**
```yaml
hpa:
  enabled: true
  minReplicas: 2          # Mínimo para produção
  maxReplicas: 10         # Máximo conforme demanda
  targetCPUUtilizationPercentage: 70  # Ajuste conforme perfil
```

#### **Segurança (Produção)**
```yaml
rbac:
  enabled: true  # Habilitar em produção

securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000
```

## Comandos Helm

### Instalação
```bash
helm install meu-release ./matcarv-kube-helm -f values.yaml
```

### Atualização
```bash
helm upgrade meu-release ./matcarv-kube-helm -f values.yaml
```

### Visualização de templates
```bash
helm template meu-release ./matcarv-kube-helm -f values.yaml
```

### Desinstalação
```bash
helm uninstall meu-release
```

## Recursos Implementados

- **Segurança**: Separação de dados sensíveis em Secrets
- **Configurabilidade**: Values.yaml flexível para diferentes ambientes
- **Auto-scaling**: HPA configurável para demanda variável
- **Controle de recursos**: ResourceQuota e limits/requests
- **Exposição**: Service + Ingress para acesso interno e externo
- **RBAC**: Controle de acesso opcional
- **Observabilidade**: Labels e seletores consistentes
- **Health Checks**: Probes de liveness e readiness
- **Segurança**: Security contexts configurados

## Boas Práticas de Segurança

- **NUNCA** versionar credenciais no `values.yaml`
- Utilizar Secrets para dados sensíveis
- Configurar resource limits adequados
- Habilitar RBAC em produção
- Usar ferramentas de CI/CD para injeção segura de valores
- Configurar security contexts apropriados
- Implementar health checks

## Personalização por Ambiente

Crie arquivos de values específicos para cada ambiente:

### `values-dev.yaml`
```yaml
app:
  replicaCount: 1
resources:
  limits:
    cpu: 500m
    memory: 1Gi
hpa:
  enabled: false
rbac:
  enabled: false
```

### `values-prod.yaml`
```yaml
app:
  replicaCount: 3
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
hpa:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
rbac:
  enabled: true
```

### Deploy por ambiente:
```bash
# Desenvolvimento
helm install app-dev ./matcarv-kube-helm -f values-dev.yaml

# Produção
helm install app-prod ./matcarv-kube-helm -f values-prod.yaml
```
