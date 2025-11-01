# 🎬 Giphy Ultimate

**O melhor app de GIFs do mundo!** Um aplicativo Flutter completo e poderoso para descobrir, organizar e compartilhar GIFs do Giphy.

[![Flutter](https://img.shields.io/badge/Flutter-3.9.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Recursos Principais

### 🎯 Descoberta de GIFs
- ✅ **GIFs Aleatórios** - Descubra novos GIFs surpreendentes
- ✅ **Trending** - Veja os GIFs mais populares do momento
- ✅ **Busca Avançada** - Encontre qualquer GIF com busca inteligente
- ✅ **Autocomplete** - Sugestões instantâneas enquanto você digita
- ✅ **Categorias** - Explore por categorias (Reações, Animais, Esportes, etc.)
- ✅ **Auto-Shuffle** - Troca automática de GIFs a cada 7 segundos

### 📱 Organização
- ✅ **Favoritos** - Salve seus GIFs preferidos
- ✅ **Coleções** - Organize GIFs em coleções personalizadas
- ✅ **Histórico de Busca** - Acesse suas buscas anteriores
- ✅ **Sincronização Local** - Dados salvos localmente com SharedPreferences

### 🎮 Gamificação
- ✅ **Sistema de Pontos** - Ganhe pontos por cada ação
- ✅ **Níveis** - Suba de nível conforme usa o app
- ✅ **Conquistas** - Desbloqueie badges especiais
- ✅ **Sequência Diária** - Mantenha sua sequência de dias ativos
- ✅ **Estatísticas Detalhadas** - Acompanhe seu progresso

### 🎨 Interface & UX
- ✅ **Material Design 3** - Interface moderna e bonita
- ✅ **Tema Claro/Escuro** - Alterne entre temas ou use o tema do sistema
- ✅ **Animações Suaves** - Transições e animações fluidas
- ✅ **Design Responsivo** - Funciona perfeitamente em todos os tamanhos de tela
- ✅ **Player Customizado** - Controles avançados para GIFs

### 🔧 Funcionalidades Avançadas
- ✅ **Compartilhamento** - Compartilhe GIFs em qualquer app
- ✅ **Download** - Baixe GIFs para seu dispositivo
- ✅ **Cache Inteligente** - Sistema de cache otimizado
- ✅ **Analytics** - Rastreamento de eventos (preparado para Firebase)
- ✅ **Tratamento de Erros** - Feedback visual claro para erros de rede/API
- ✅ **Arquitetura MVVM** - Código limpo e organizado

## 🚀 Começando

### Pré-requisitos

- Flutter SDK 3.9.0 ou superior
- Dart 3.9.0 ou superior
- Android Studio / VS Code
- Conta no [Giphy Developers](https://developers.giphy.com/)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/giphy-ultimate.git
cd giphy-ultimate
```

2. **Configure a API Key do Giphy**
   - Acesse [Giphy Developers](https://developers.giphy.com/)
   - Crie uma conta e obtenha sua API Key
   - Copie o arquivo `.env.example` para `.env`:
   ```bash
   # Windows PowerShell
   Copy-Item .env.example .env
   
   # Linux/Mac
   cp .env.example .env
   ```
   - Abra o arquivo `.env` e substitua `YOUR_API_KEY_HERE` pela sua API Key:
   ```
   GIPHY_API_KEY=sua_api_key_aqui
   ```

3. **Instale as dependências**
```bash
flutter pub get
```

4. **Execute o app**
```bash
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── config/              # Configurações do app
│   └── routes.dart      # Sistema de rotas
├── constants/           # Constantes globais
│   ├── app_colors.dart  # Paleta de cores
│   ├── app_constants.dart # Constantes gerais
│   └── app_strings.dart # Strings do app
├── models/              # Modelos de dados
│   ├── achievement_model.dart
│   ├── collection_model.dart
│   ├── comment_model.dart
│   ├── favorite_model.dart
│   ├── gif_model.dart
│   ├── reaction_model.dart
│   ├── search_history_model.dart
│   ├── user_model.dart
│   └── user_stats_model.dart
├── services/            # Camada de serviços
│   ├── analytics_service.dart
│   ├── cache_service.dart
│   ├── download_service.dart
│   ├── gamification_service.dart
│   ├── giphy_service.dart
│   ├── share_service.dart
│   └── storage_service.dart
├── viewmodels/          # Lógica de negócios (MVVM)
│   ├── collection_viewmodel.dart
│   ├── gif_viewmodel.dart
│   ├── search_viewmodel.dart
│   ├── theme_viewmodel.dart
│   └── user_viewmodel.dart
├── views/               # Interface do usuário
│   ├── screens/         # Telas principais
│   │   ├── collections_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── home_screen.dart
│   │   ├── main_screen.dart
│   │   ├── profile_screen.dart
│   │   └── search_screen.dart
│   └── widgets/         # Widgets reutilizáveis
│       ├── achievement_badge.dart
│       ├── category_chip.dart
│       ├── gif_card.dart
│       ├── gif_player.dart
│       └── stat_card.dart
├── utils/               # Utilitários
│   ├── app_theme.dart   # Temas do app
│   └── helpers.dart     # Funções auxiliares
└── main.dart            # Ponto de entrada
```

## 🏗️ Arquitetura

Este projeto utiliza a arquitetura **MVVM (Model-View-ViewModel)** com **Provider** para gerenciamento de estado.

### Camadas:

1. **Models** - Representam os dados da aplicação
2. **Services** - Lógica de acesso a dados (API, Storage, etc.)
3. **ViewModels** - Lógica de negócios e estado da aplicação
4. **Views** - Interface do usuário (Screens e Widgets)

### Fluxo de Dados:
```
View → ViewModel → Service → API/Storage
                ↓
            notifyListeners()
                ↓
            View (rebuild)
```

## 📦 Principais Dependências

### UI & Widgets
- `cached_network_image` - Cache de imagens
- `flutter_staggered_grid_view` - Grids personalizados
- `shimmer` - Efeitos de loading
- `lottie` - Animações

### State Management
- `provider` - Gerenciamento de estado

### Network & API
- `http` - Requisições HTTP
- `dio` - Cliente HTTP avançado

### Storage
- `shared_preferences` - Armazenamento local
- `hive` - Banco de dados NoSQL
- `sqflite` - Banco de dados SQL
- `path_provider` - Caminhos do sistema

### Utilities
- `uuid` - Geração de IDs únicos
- `intl` - Internacionalização e formatação
- `timeago` - Tempo relativo
- `equatable` - Comparação de objetos

### Sharing & Social
- `share_plus` - Compartilhamento
- `url_launcher` - Abrir URLs

## 🎯 Funcionalidades Implementadas

### ✅ Core Features
- [x] Busca de GIFs (Giphy API)
- [x] GIFs Aleatórios
- [x] GIFs Trending
- [x] Auto-Shuffle
- [x] Player de GIFs com controles
- [x] Sistema de favoritos
- [x] Coleções de GIFs
- [x] Histórico de buscas
- [x] Autocomplete

### ✅ Gamificação
- [x] Sistema de pontos
- [x] Níveis de usuário
- [x] Conquistas (17 diferentes)
- [x] Sequência diária
- [x] Estatísticas detalhadas

### ✅ UI/UX
- [x] Tema claro/escuro
- [x] Material Design 3
- [x] Navegação por abas
- [x] Busca com sugestões
- [x] Grid responsivo de GIFs
- [x] Animações suaves

### ✅ Outros
- [x] Compartilhamento de GIFs
- [x] Download de GIFs
- [x] Cache inteligente
- [x] Analytics (base implementada)
- [x] Tratamento de erros com feedback visual
- [x] Configuração via arquivo `.env`

## 🔮 Funcionalidades Futuras

### 📱 Features Planejados
- [ ] Editor de GIFs básico
- [ ] Criação de GIFs da câmera/galeria
- [ ] Sistema de notificações
- [ ] GIF do dia
- [ ] Widgets para home screen
- [ ] Integração com Firebase
  - [ ] Authentication (Google, Facebook, Apple)
  - [ ] Cloud Firestore (sync entre dispositivos)
  - [ ] Firebase Analytics
  - [ ] Crash Reporting
- [ ] Teclado de GIFs (Android/iOS)
- [ ] Recursos sociais
  - [ ] Comentários
  - [ ] Reações
  - [ ] Seguir usuários
  - [ ] Coleções públicas
- [ ] IA e ML
  - [ ] Recomendações personalizadas
  - [ ] Busca por similaridade
  - [ ] Detecção de conteúdo
- [ ] Recursos Premium
  - [ ] Remoção de anúncios
  - [ ] Editor avançado
  - [ ] Storage ilimitado na nuvem
  - [ ] Recursos exclusivos

### 🎨 Melhorias de UI/UX
- [ ] Modo Picture-in-Picture
- [ ] Gestos avançados (swipe, pinch-to-zoom)
- [ ] Mais temas personalizáveis
- [ ] Haptic feedback
- [ ] Splash screen animada
- [ ] Onboarding para novos usuários

### ⚡ Performance
- [ ] Pre-loading de GIFs
- [ ] Compressão adaptativa
- [ ] Suporte a WebP
- [ ] Background refresh
- [ ] Otimizações de memória

## 🎮 Sistema de Gamificação

### Pontos por Ação
- Visualizar GIF: **1 ponto**
- Favoritar GIF: **5 pontos**
- Compartilhar GIF: **10 pontos**
- Comentar: **15 pontos**
- Criar Coleção: **20 pontos**
- Login Diário: **25 pontos**

### Níveis
O nível é calculado com base nos pontos totais:
- **Nível** = √(pontos / 100) + 1
- **Pontos para próximo nível** = (nível²) × 100

Exemplo:
- Nível 1: 0-99 pontos
- Nível 2: 100-399 pontos
- Nível 3: 400-899 pontos
- Nível 4: 900-1599 pontos

### Conquistas
17 conquistas disponíveis em 4 raridades:
- ⚪ **Comum** (9 conquistas)
- 🔵 **Rara** (5 conquistas)
- 🟣 **Épica** (2 conquistas)
- 🟡 **Lendária** (2 conquistas)

Categorias:
- 👁️ **Visualizador** - Por visualizar GIFs
- 📦 **Colecionador** - Por favoritos e coleções
- 🦋 **Social** - Por compartilhar e comentar
- 🗺️ **Explorador** - Por explorar categorias

## 🔑 API do Giphy

Este app utiliza a [Giphy API](https://developers.giphy.com/docs/api) para buscar GIFs.

### Endpoints Utilizados:
- `GET /v1/gifs/random` - GIF aleatório
- `GET /v1/gifs/trending` - GIFs em alta
- `GET /v1/gifs/search` - Busca de GIFs
- `GET /v1/gifs/search/tags` - Autocomplete
- `GET /v1/trending/searches` - Buscas em alta
- `GET /v1/gifs` - GIFs por IDs

### Rate Limits:
- **Gratuito**: 42 requests/hora, 1000 requests/dia
- **Beta**: 1000 requests/hora

## ⚠️ Notas Importantes

- **Arquivo `.env`**: Este arquivo contém sua API Key e não deve ser commitado no Git. Ele já está no `.gitignore`.
- **`.env.example`**: Template do arquivo de configuração. Use como referência para criar seu próprio `.env`.
- **Tratamento de Erros**: O app exibe mensagens de erro claras para problemas de conexão, API Key inválida ou erros do servidor.

## 🛠️ Desenvolvimento

### Rodar em modo de desenvolvimento
```bash
flutter run --debug
```

### Build para produção
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Rodar testes
```bash
flutter test
```

### Análise de código
```bash
flutter analyze
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📝 Convenções de Código

- Siga o [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter format` antes de commitar
- Adicione comentários em código complexo
- Mantenha funções pequenas e focadas
- Use nomes descritivos para variáveis e funções

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Seu Nome**
- GitHub: [@seu-usuario](https://github.com/seu-usuario)
- Email: seu.email@example.com

## 🙏 Agradecimentos

- [Giphy](https://giphy.com/) - Por fornecer a API incrível
- [Flutter](https://flutter.dev/) - Framework fantástico
- Comunidade Flutter - Por todo o suporte

## 📞 Suporte

Se você tiver alguma dúvida ou problema:

1. Verifique a seção de [Issues](https://github.com/seu-usuario/giphy-ultimate/issues)
2. Abra uma nova issue se necessário
3. Entre em contato: seu.email@example.com

---

**⭐ Se você gostou deste projeto, deixe uma estrela no GitHub!**

Feito com ❤️ e Flutter 🎯

