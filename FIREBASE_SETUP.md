# 🔥 Guia de Configuração do Firebase

## Por que o Firebase não está funcionando?

### Problemas Identificados:

1. **iOS**: Falta arquivo `GoogleService-Info.plist`
2. **Android**: Arquivo `google-services.json` existe mas pode estar incorreto
3. **Código**: Muitas funcionalidades Firebase estão comentadas (Analytics, Auth, etc.)

---

## 📱 Como Configurar Firebase para iOS

### Passo 1: Obter GoogleService-Info.plist

1. Acesse: https://console.firebase.google.com/
2. Selecione o projeto: **giphys-8b193**
3. Vá em: ⚙️ **Configurações do Projeto** → **Seus apps**
4. Se não tiver app iOS:
   - Clique em **Adicionar app** → escolha **iOS**
   - **Bundle ID**: `com.grupo6.giphy`
   - **Nome do app**: Giphy Ultimate (opcional)
   - Clique em **Registrar app**
5. Baixe o arquivo `GoogleService-Info.plist`
6. Coloque em: `ios/Runner/GoogleService-Info.plist`

### Passo 2: Adicionar ao Xcode (se necessário)

1. Abra o projeto no Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. No Xcode, arraste o `GoogleService-Info.plist` para a pasta `Runner`
3. Certifique-se de que está marcado no Target `Runner`

---

## 🤖 Como Configurar Firebase para Android

### Verificar google-services.json

O arquivo `android/app/google-services.json` já existe, mas verifique:

1. Abra o arquivo e verifique se o `package_name` está correto:
   ```json
   "package_name": "com.grupo6.giphy"
   ```
2. Se estiver diferente, baixe novamente do Firebase Console:
   - Firebase Console → Configurações → Seus apps → Android
   - Baixe o `google-services.json` atualizado
   - Substitua o arquivo em `android/app/`

---

## 🔧 Ativar Funcionalidades Firebase no Código

### 1. Firebase Analytics

O código está preparado mas comentado. Para ativar:

**Arquivo**: `lib/services/analytics_service.dart`

Descomente as linhas:
```dart
// Linha 23-27
await FirebaseAnalytics.instance.logEvent(
  name: name,
  parameters: parameters,
);

// Linha 104-107
await FirebaseAnalytics.instance.setUserProperty(
  name: name,
  value: value,
);

// Linha 120
await FirebaseAnalytics.instance.setUserId(id: userId);
```

E adicione o import:
```dart
import 'package:firebase_analytics/firebase_analytics.dart';
```

### 2. Firebase Authentication

Para usar autenticação, você precisa:

1. **Ativar no Firebase Console**:
   - Firebase Console → Authentication → Sign-in method
   - Ative os métodos desejados (Google, Email/Password, etc.)

2. **Implementar no código**:
   - Criar um serviço de autenticação
   - Usar `FirebaseAuth.instance`

### 3. Cloud Firestore

Para usar Firestore:

1. **Ativar no Firebase Console**:
   - Firebase Console → Firestore Database → Criar banco de dados

2. **Usar no código**:
   ```dart
   import 'package:cloud_firestore/cloud_firestore.dart';
   
   final db = Firestore.instance;
   ```

### 4. Firebase Storage

Para usar Storage:

1. **Ativar no Firebase Console**:
   - Firebase Console → Storage → Começar

2. **Usar no código**:
   ```dart
   import 'package:firebase_storage/firebase_storage.dart';
   ```

---

## ✅ Verificar se está Funcionando

### Teste no Debug

1. Execute o app:
   ```bash
   flutter run
   ```

2. Verifique os logs no console:
   - ✅ Deve aparecer: `[Main] ✅ Firebase inicializado com sucesso`
   - ✅ Deve aparecer: `[Main] ✅ Remote Config inicializado`

3. Se aparecer erro:
   - ❌ `Erro ao inicializar Firebase` → Arquivo de configuração faltando ou incorreto
   - ❌ `Remote Config não inicializado` → Firebase não inicializou

### Teste na Tela de Debug do App

No app, vá para:
- **Perfil** → **Tela de Debug**

Verifique:
- ✅ Firebase Status: Disponível
- ✅ API Key Status: Configurada
- ✅ Remote Config: Disponível

---

## 🚨 Problemas Comuns

### Erro: "FirebaseOptions cannot be null"

**Causa**: Arquivo de configuração não encontrado

**Solução**:
- iOS: Adicione `GoogleService-Info.plist` em `ios/Runner/`
- Android: Verifique se `google-services.json` está em `android/app/`

### Erro: "Default FirebaseApp is not initialized"

**Causa**: Firebase não inicializou antes de usar

**Solução**: Verifique se `Firebase.initializeApp()` está sendo chamado no `main.dart` (já está)

### Erro: "Missing google-services.json"

**Causa**: Arquivo não encontrado ou incorreto

**Solução**: 
- Baixe novamente do Firebase Console
- Verifique se o `package_name` está correto

---

## 📝 Checklist de Configuração

- [ ] iOS: `GoogleService-Info.plist` adicionado em `ios/Runner/`
- [ ] Android: `google-services.json` verificado em `android/app/`
- [ ] Firebase Console: Projeto configurado
- [ ] Firebase Console: App iOS adicionado (Bundle ID: `com.grupo6.giphy`)
- [ ] Firebase Console: App Android verificado (Package: `com.grupo6.giphy`)
- [ ] Teste: Firebase inicializa sem erros
- [ ] Teste: Remote Config funciona
- [ ] (Opcional) Analytics descomentado no código
- [ ] (Opcional) Auth configurado no Firebase Console
- [ ] (Opcional) Firestore criado no Firebase Console

---

## 🎯 Próximos Passos

1. **Imediato**: Adicionar `GoogleService-Info.plist` para iOS
2. **Opcional**: Descomentar código de Analytics
3. **Futuro**: Implementar Auth, Firestore, Storage conforme necessário

