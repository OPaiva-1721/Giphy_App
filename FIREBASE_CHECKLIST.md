# ✅ Checklist de Configuração do Firebase

## Configurações Realizadas

- ✅ `google-services.json` renomeado e colocado em `android/app/`
- ✅ Plugin `com.google.gms.google-services` adicionado ao `build.gradle.kts`
- ✅ Firebase Remote Config configurado no código
- ✅ Fallback para `.env` se Firebase não estiver disponível

## Próximos Passos para Completar a Configuração

### 1. Configurar Remote Config no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Vá para **Remote Config** no menu lateral
3. Clique em **"Adicionar parâmetro"**
4. Configure:
   - **Chave:** `giphy_api_key`
   - **Valor padrão:** Coloque sua API Key atual do GIPHY
   - **Tipo:** String
5. Clique em **"Publicar alterações"**

### 2. Testar a Configuração

1. Execute o app:
   ```bash
   flutter run
   ```

2. Verifique os logs. Você deve ver:
   ```
   [Main] Firebase inicializado com sucesso
   [Main] Remote Config inicializado
   [RemoteConfigService] Configurações remotas carregadas
   ```

3. Se estiver usando Remote Config:
   ```
   [RemoteConfigService] Usando API key do Remote Config
   ```

4. Se estiver usando fallback:
   ```
   [RemoteConfigService] Usando API key local (.env ou hardcoded)
   ```

### 3. Configurar iOS (Se Aplicável)

Se você também vai compilar para iOS:
1. Adicione o arquivo `GoogleService-Info.plist` em `ios/Runner/`
2. Abra `ios/Runner.xcworkspace` no Xcode
3. O arquivo será detectado automaticamente

### 4. Verificar Build do Android

Antes de fazer build de release, teste se compila:
```bash
flutter build apk --debug
```

Se houver erros relacionados ao Google Services, verifique:
- O arquivo `google-services.json` está em `android/app/`
- O plugin está declarado no `build.gradle.kts` do app
- O plugin está no `settings.gradle.kts` no nível raiz

## Como Atualizar a API Key Quando Expirar

1. **No Firebase Console:**
   - Remote Config → `giphy_api_key` → Editar
   - Cole a nova chave
   - Publicar alterações

2. **Os apps atualizam automaticamente:**
   - Apps em execução: dentro de 1 hora (ou na próxima vez que abrir)
   - Apps recém-instalados: imediatamente

3. **Não precisa:**
   - ❌ Lançar nova versão do app
   - ❌ Atualizar na Play Store/App Store
   - ❌ Fazer rebuild do código

## Troubleshooting

### Firebase não inicializa

**Sintoma:** Log mostra `Firebase não configurado`

**Soluções:**
1. Verifique se `google-services.json` está em `android/app/`
2. Verifique se o plugin está no `build.gradle.kts`
3. Tente fazer `flutter clean` e `flutter pub get`
4. Certifique-se que o `package_name` no JSON corresponde ao `applicationId` no `build.gradle.kts`

### Remote Config não busca valores

**Sintoma:** Log mostra usando chave local mesmo com Firebase configurado

**Soluções:**
1. Verifique se o parâmetro `giphy_api_key` foi **publicado** (não apenas salvo)
2. Aguarde até 1 hora (tempo mínimo de cache)
3. Verifique a conexão de internet do dispositivo

### Erro de compilação no Android

**Sintoma:** Build falha com erro do Google Services

**Soluções:**
1. Verifique se o plugin está no `settings.gradle.kts`
2. Verifique se a versão do plugin é compatível
3. Tente `flutter clean` e `flutter pub get`

## Status Atual

✅ **Código configurado** - Pronto para usar
✅ **Android configurado** - `google-services.json` no lugar
⏳ **Remote Config** - Precisa configurar no Console (opcional)
⏳ **iOS** - Não configurado (se aplicável)

O app funciona normalmente mesmo sem configurar Remote Config, usando `.env` como fallback!

