import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt')
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get appName;

  /// No description provided for @notes.
  ///
  /// In pt, this message translates to:
  /// **'Anotações'**
  String get notes;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @desconect.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get desconect;

  /// No description provided for @homeLogin.
  ///
  /// In pt, this message translates to:
  /// **'Bem vindo ao nosso app, aproveite 😁'**
  String get homeLogin;

  /// No description provided for @googleLogin.
  ///
  /// In pt, this message translates to:
  /// **'Login com Google'**
  String get googleLogin;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @newTask.
  ///
  /// In pt, this message translates to:
  /// **'Nova Tarefa'**
  String get newTask;

  /// No description provided for @newNote.
  ///
  /// In pt, this message translates to:
  /// **'Nova Anotação'**
  String get newNote;

  /// No description provided for @saveNote.
  ///
  /// In pt, this message translates to:
  /// **'Anotação salva com sucesso!'**
  String get saveNote;

  /// No description provided for @errosaveNote.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar anotação.'**
  String get errosaveNote;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @notesDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da Anotação'**
  String get notesDetails;

  /// No description provided for @inputTask.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua tarefa'**
  String get inputTask;

  /// No description provided for @inputNote.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua anotação'**
  String get inputNote;

  /// No description provided for @errorLoadNotes.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar anotações'**
  String get errorLoadNotes;

  /// No description provided for @noTask.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa encontrada 😅'**
  String get noTask;

  /// No description provided for @noNotes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma anotação encontrada 😅'**
  String get noNotes;

  /// No description provided for @confirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteSub.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza de que deseja excluir esta anotação?'**
  String get confirmDeleteSub;

  /// No description provided for @about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about;

  /// No description provided for @copyright.
  ///
  /// In pt, this message translates to:
  /// **'Todos os direitos reservados'**
  String get copyright;

  /// No description provided for @appDesc.
  ///
  /// In pt, this message translates to:
  /// **'Organize suas tarefas e anotações diárias.'**
  String get appDesc;

  /// No description provided for @version.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get version;

  /// No description provided for @privacy.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacy;

  /// No description provided for @privacySub.
  ///
  /// In pt, this message translates to:
  /// **'Termos que garantem a sua privacidade'**
  String get privacySub;

  /// No description provided for @sourceCode.
  ///
  /// In pt, this message translates to:
  /// **'Código Fonte'**
  String get sourceCode;

  /// No description provided for @sourceCodeSub.
  ///
  /// In pt, this message translates to:
  /// **'Projeto disponível no GitHub'**
  String get sourceCodeSub;

  /// No description provided for @openSource.
  ///
  /// In pt, this message translates to:
  /// **'Licenças de Código Aberto'**
  String get openSource;

  /// No description provided for @openSourceSub.
  ///
  /// In pt, this message translates to:
  /// **'Softwares de terceiros usados na construção do app'**
  String get openSourceSub;

  /// No description provided for @interface.
  ///
  /// In pt, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @others.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get others;

  /// No description provided for @theme.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeSub.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o tema que mais combina com você'**
  String get themeSub;

  /// No description provided for @themeSelect.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o Tema'**
  String get themeSelect;

  /// No description provided for @darkMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo Escuro'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo Claro'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In pt, this message translates to:
  /// **'Padrão do Sistema'**
  String get systemMode;

  /// No description provided for @dynamicColors.
  ///
  /// In pt, this message translates to:
  /// **'Dynamic Colors'**
  String get dynamicColors;

  /// No description provided for @dynamicColorsSub.
  ///
  /// In pt, this message translates to:
  /// **'Proporciona uma interface agradável de acordo com o seu papel de parede'**
  String get dynamicColorsSub;

  /// No description provided for @update.
  ///
  /// In pt, this message translates to:
  /// **'Atualizações'**
  String get update;

  /// No description provided for @updateSub.
  ///
  /// In pt, this message translates to:
  /// **'Procurar por novas versões do app'**
  String get updateSub;

  /// No description provided for @support.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get support;

  /// No description provided for @supportSub.
  ///
  /// In pt, this message translates to:
  /// **'Encontrou um bug ou deseja sugerir algo?'**
  String get supportSub;

  /// No description provided for @review.
  ///
  /// In pt, this message translates to:
  /// **'Avalie o App'**
  String get review;

  /// No description provided for @reviewSub.
  ///
  /// In pt, this message translates to:
  /// **'Faça uma avaliação na loja de apps'**
  String get reviewSub;

  /// No description provided for @aboutSub.
  ///
  /// In pt, this message translates to:
  /// **'Um pouco mais sobre o app'**
  String get aboutSub;

  /// No description provided for @newUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Nova versão disponível'**
  String get newUpdate;

  /// No description provided for @news.
  ///
  /// In pt, this message translates to:
  /// **'Novidades:'**
  String get news;

  /// No description provided for @after.
  ///
  /// In pt, this message translates to:
  /// **'DEPOIS'**
  String get after;

  /// No description provided for @download.
  ///
  /// In pt, this message translates to:
  /// **'BAIXAR'**
  String get download;

  /// No description provided for @noUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma atualização disponível'**
  String get noUpdate;

  /// No description provided for @noUpdateSub.
  ///
  /// In pt, this message translates to:
  /// **'Tudo em dias parceiro 🤠'**
  String get noUpdateSub;

  /// No description provided for @pendants.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get pendants;

  /// No description provided for @completed.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get completed;

  /// No description provided for @dateTime.
  ///
  /// In pt, this message translates to:
  /// **'Selecione a data e hora'**
  String get dateTime;

  /// No description provided for @taskDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da Tarefa'**
  String get taskDetails;

  /// No description provided for @notificationTask.
  ///
  /// In pt, this message translates to:
  /// **'Opa, tudo bem? Aqui esta o seu lembrete'**
  String get notificationTask;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @inputDateError.
  ///
  /// In pt, this message translates to:
  /// **'A data e hora são necessárias'**
  String get inputDateError;

  /// No description provided for @inputTaskError.
  ///
  /// In pt, this message translates to:
  /// **'Não e possível adicionar uma tarefa em branco'**
  String get inputTaskError;

  /// No description provided for @inputNoteError.
  ///
  /// In pt, this message translates to:
  /// **'Não e possível salvar uma anotação em branco'**
  String get inputNoteError;

  /// No description provided for @notification.
  ///
  /// In pt, this message translates to:
  /// **'Notificações'**
  String get notification;

  /// No description provided for @notificationSub.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes serão enviadas informando sobre suas tarefas'**
  String get notificationSub;

  /// No description provided for @confirmDeleteTask.
  ///
  /// In pt, this message translates to:
  /// **'Deseja realmente apagar a tarefa?'**
  String get confirmDeleteTask;

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @alreadyReviewed.
  ///
  /// In pt, this message translates to:
  /// **'Você já avaliou o app'**
  String get alreadyReviewed;

  /// No description provided for @dateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Data da Tarefa'**
  String get dateTitle;

  /// No description provided for @noDate.
  ///
  /// In pt, this message translates to:
  /// **'Sem Agendamento'**
  String get noDate;

  /// No description provided for @taskTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título da Tarefa'**
  String get taskTitle;

  /// No description provided for @errorUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível verificar atualizações.'**
  String get errorUpdate;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @loginError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no login'**
  String get loginError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
