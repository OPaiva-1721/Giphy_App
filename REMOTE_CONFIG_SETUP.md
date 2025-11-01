# 🔄 Como Atualizar a API Key Sem Nova Versão do App

Este projeto usa **Firebase Remote Config** para permitir atualizar a API Key do GIPHY remotamente, sem precisar lançar uma nova versão do app nas lojas.

## 📋 Como Funciona

1. **Prioridade de carregamento da API Key:**
   - 1º: Firebase Remote Config (configuração remota)
   - 2º: Arquivo `.env` (local)
   - 3º: Hardcoded (fallback)

2. **Se o Firebase não estiver configurado:**
   - O app continua funcionando normalmente usando `.env` ou hardcoded
   - Não quebra se o Firebase falhar

## 🚀 Configuração Inicial

### 1. Configure o Firebase no seu projeto

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/)
2. Adicione apps Android/iOS ao projeto
3. Baixe os arquivos de configuração:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

### 2. Configure o Remote Config

1. No Firebase Console, vá para **Remote Config**
2. Clique em **"Adicionar parâmetro"**
3. Configure:
   - **Chave:** `giphy_api_key`
   - **Valor padrão:** Sua API Key atual do GIPHY
   - **Tipo:** String

4. Clique em **"Publicar alterações"**

## 📝 Atualizando a API Key Quando Expirar

### Opção 1: Via Firebase Console (Recomendado)

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Vá para **Remote Config**
3. Encontre o parâmetro `giphy_api_key`
4. Clique em **Editar**
5. Substitua pelo novo valor
6. Clique em **"Publicar alterações"**

**Pronto!** Todos os apps em execução irão buscar automaticamente a nova chave dentro de 1 hora (configuração padrão).

### Opção 2: Forçar Atualização Imediata (Opcional)

Se quiser que os apps atualizem imediatamente, você pode adicionar um botão "Atualizar Configurações" na tela de configurações do app (opcional).

## ⚙️ Configurações Avançadas

### Tempo de Cache

O Remote Config está configurado para:
- **Fetch timeout:** 10 segundos
- **Minimum fetch interval:** 1 hora (apps buscam no máximo 1x por hora)

Para mudar, edite `lib/services/remote_config_service.dart`:

```dart
RemoteConfigSettings(
  fetchTimeout: const Duration(seconds: 10),
  minimumFetchInterval: const Duration(hours: 1), // Altere aqui
)
```

### Valores Padrão

Se o Firebase falhar, o app usa o valor padrão definido em:
- `.env` → `GIPHY_API_KEY=sua_chave`
- Ou hardcoded em `AppConstants.giphyApiKey`

## 🔍 Debugging

### Verificar se está funcionando

Nos logs do app, você verá:
- `[RemoteConfigService] Configurações remotas carregadas` - ✅ Funcionando
- `[RemoteConfigService] Usando API key do Remote Config` - ✅ Usando remoto
- `[RemoteConfigService] Usando API key local` - ⚠️ Usando fallback

### Se não estiver funcionando

1. Verifique se o Firebase está inicializado:
   ```
   [Main] Firebase inicializado com sucesso
   ```

2. Verifique se o Remote Config tem o parâmetro `giphy_api_key` configurado

3. Verifique se o parâmetro foi publicado (não apenas salvo como rascunho)

4. Os apps podem levar até 1 hora para buscar atualizações (configuração padrão)

## 💡 Dicas Importantes

1. **Sempre mantenha um fallback:** Mantenha a API key no `.env` como backup
2. **Teste antes de expirar:** Quando souber que vai expirar, atualize no Remote Config com alguns dias de antecedência
3. **Monitoramento:** Configure alertas no Firebase se a API key falhar

## 🆘 Sem Firebase?

Se você não quiser usar Firebase, o app continua funcionando normalmente usando:
- Arquivo `.env` local (recomendado para desenvolvimento)
- Hardcoded na compilação (não recomendado para produção)

Nesse caso, será necessário lançar nova versão do app quando a API key expirar.

