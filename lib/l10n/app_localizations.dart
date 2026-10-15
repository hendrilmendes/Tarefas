import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appName.
  ///
  /// In pt, this message translates to:
  /// **'Tá na Lista'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas'**
  String get home;

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
  /// **'Nenhuma tarefa encontrada'**
  String get noTask;

  /// No description provided for @noNotes.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma anotação encontrada'**
  String get noNotes;

  /// No description provided for @confirmDelete.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteNote.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza de que deseja excluir esta anotação?'**
  String get confirmDeleteNote;

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
  /// **'Softwares de terceiros usados no app'**
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

  /// No description provided for @themeSelect.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o Tema'**
  String get themeSelect;

  /// No description provided for @darkMode.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get lightMode;

  /// No description provided for @systemMode.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
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
  /// **'Você já está com a última versão do app'**
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
  /// **'Não se esqueça'**
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
  /// **'Notificações sobre suas tarefas'**
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

  /// No description provided for @personalization.
  ///
  /// In pt, this message translates to:
  /// **'Personalização'**
  String get personalization;

  /// No description provided for @personalizationSub.
  ///
  /// In pt, this message translates to:
  /// **'Personalize o app da forma que quiser'**
  String get personalizationSub;

  /// No description provided for @color.
  ///
  /// In pt, this message translates to:
  /// **'Cor'**
  String get color;

  /// No description provided for @accentColor.
  ///
  /// In pt, this message translates to:
  /// **'Cor de Destaque'**
  String get accentColor;

  /// No description provided for @dynamicColorsEnabledWarning.
  ///
  /// In pt, this message translates to:
  /// **'O Dynamic Colors esta ativado'**
  String get dynamicColorsEnabledWarning;

  /// No description provided for @information.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get information;

  /// No description provided for @displayMode.
  ///
  /// In pt, this message translates to:
  /// **'Modo de Exibição'**
  String get displayMode;

  /// No description provided for @addTasks.
  ///
  /// In pt, this message translates to:
  /// **'Toque no botão + para criar sua primeira tarefa'**
  String get addTasks;

  /// No description provided for @addNotes.
  ///
  /// In pt, this message translates to:
  /// **'Toque no botão + para criar sua primeira nota'**
  String get addNotes;

  /// No description provided for @acceptTerms.
  ///
  /// In pt, this message translates to:
  /// **'Ao continuar, você concorda com a nossa '**
  String get acceptTerms;

  /// No description provided for @welcomeMessageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Organize seu dia,'**
  String get welcomeMessageTitle;

  /// No description provided for @welcomeMessageSub.
  ///
  /// In pt, this message translates to:
  /// **'alcance seus objetivos.'**
  String get welcomeMessageSub;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Desconectar'**
  String get logoutConfirm;

  /// No description provided for @logoutConfirmSub.
  ///
  /// In pt, this message translates to:
  /// **'Você tem certeza que quer desconectar do app?'**
  String get logoutConfirmSub;

  /// No description provided for @greetingNight.
  ///
  /// In pt, this message translates to:
  /// **'Boa madrugada'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In pt, this message translates to:
  /// **'Bom dia'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In pt, this message translates to:
  /// **'Boa tarde'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In pt, this message translates to:
  /// **'Boa noite'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In pt, this message translates to:
  /// **'{greeting}, {name} 👋'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @you.
  ///
  /// In pt, this message translates to:
  /// **'você'**
  String get you;

  /// No description provided for @briefingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Você está com a agenda livre. Que tal planejar o dia em 3 metas?'**
  String get briefingEmpty;

  /// No description provided for @briefingOverdueToday.
  ///
  /// In pt, this message translates to:
  /// **'Você tem {overdue, plural, =1{1 atrasada} other{{overdue} atrasadas}} e {today} para hoje. Vamos limpar as atrasadas primeiro.'**
  String briefingOverdueToday(int overdue, int today);

  /// No description provided for @briefingOverdue.
  ///
  /// In pt, this message translates to:
  /// **'Você tem {overdue, plural, =1{1 tarefa atrasada} other{{overdue} tarefas atrasadas}}. Recomendo reagendar ou concluir agora.'**
  String briefingOverdue(int overdue);

  /// No description provided for @briefingToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje você tem {today, plural, =1{1 tarefa} other{{today} tarefas}}. Bom ritmo — foque na primeira abaixo.'**
  String briefingToday(int today);

  /// No description provided for @briefingPending.
  ///
  /// In pt, this message translates to:
  /// **'Nada para hoje, mas há {count, plural, =1{1 pendente} other{{count} pendentes}} à frente. Que tal adiantar uma?'**
  String briefingPending(int count);

  /// No description provided for @briefingAllDone.
  ///
  /// In pt, this message translates to:
  /// **'Tudo concluído. Dia limpo — aproveite para revisar as notas.'**
  String get briefingAllDone;

  /// No description provided for @suggestionFocus.
  ///
  /// In pt, this message translates to:
  /// **'Sugestão: comece por \"{title}\" ({when}). Divida em passos de 10 min se travar.'**
  String suggestionFocus(String title, String when);

  /// No description provided for @suggestionCreate.
  ///
  /// In pt, this message translates to:
  /// **'Sugestão: crie 3 tarefas com horário — ex.: \"Amanhã 9h academia #saude\".'**
  String get suggestionCreate;

  /// No description provided for @whenNoTime.
  ///
  /// In pt, this message translates to:
  /// **'sem horário'**
  String get whenNoTime;

  /// No description provided for @whenOverdue.
  ///
  /// In pt, this message translates to:
  /// **'atrasada'**
  String get whenOverdue;

  /// No description provided for @whenToday.
  ///
  /// In pt, this message translates to:
  /// **'hoje às {time}'**
  String whenToday(String time);

  /// No description provided for @whenTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'amanhã'**
  String get whenTomorrow;

  /// No description provided for @whenInDays.
  ///
  /// In pt, this message translates to:
  /// **'em {days} dias'**
  String whenInDays(int days);

  /// No description provided for @stepsTravel.
  ///
  /// In pt, this message translates to:
  /// **'Definir datas e orçamento|Reservar transporte e hospedagem|Fazer checklist de malas|Confirmar documentos'**
  String get stepsTravel;

  /// No description provided for @stepsStudy.
  ///
  /// In pt, this message translates to:
  /// **'Separar material em 3 blocos|Estudar bloco 1 (25 min foco)|Revisar com resumos|Fazer questões/exercícios'**
  String get stepsStudy;

  /// No description provided for @stepsClean.
  ///
  /// In pt, this message translates to:
  /// **'Escolher 1 cômodo|Separar o que sai / fica|Limpar em 15 min|Guardar e fotografar o resultado'**
  String get stepsClean;

  /// No description provided for @stepsProject.
  ///
  /// In pt, this message translates to:
  /// **'Definir objetivo em 1 frase|Rascunhar estrutura|Preencher conteúdo|Revisar e enviar'**
  String get stepsProject;

  /// No description provided for @stepsWorkout.
  ///
  /// In pt, this message translates to:
  /// **'Separar roupa + água|Aquecer 5 min|Treino principal 20 min|Alongar e registrar'**
  String get stepsWorkout;

  /// No description provided for @stepsBill.
  ///
  /// In pt, this message translates to:
  /// **'Conferir valor e vencimento|Pagar no app/banco|Salvar comprovante'**
  String get stepsBill;

  /// No description provided for @stepsGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Definir o primeiro passo de 5 min|Executar sem interrupção|Revisar e marcar como feito'**
  String get stepsGeneric;

  /// No description provided for @slotToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje às {time} parece livre'**
  String slotToday(String time);

  /// No description provided for @slotTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã às 09:00 parece ideal'**
  String get slotTomorrow;

  /// No description provided for @priorityUrgent.
  ///
  /// In pt, this message translates to:
  /// **'Urgente'**
  String get priorityUrgent;

  /// No description provided for @priorityHigh.
  ///
  /// In pt, this message translates to:
  /// **'Alta'**
  String get priorityHigh;

  /// No description provided for @priorityMedium.
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get priorityMedium;

  /// No description provided for @priorityNormal.
  ///
  /// In pt, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priority.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade'**
  String get priority;

  /// No description provided for @overdue.
  ///
  /// In pt, this message translates to:
  /// **'Atrasadas'**
  String get overdue;

  /// No description provided for @today.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get tomorrow;

  /// No description provided for @noDateGroup.
  ///
  /// In pt, this message translates to:
  /// **'Sem data'**
  String get noDateGroup;

  /// No description provided for @agenda.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get agenda;

  /// No description provided for @agendaFreeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Agenda livre por aqui'**
  String get agendaFreeTitle;

  /// No description provided for @agendaFreeBody.
  ///
  /// In pt, this message translates to:
  /// **'Nada nos próximos 14 dias.\n{tip}.'**
  String agendaFreeBody(String tip);

  /// No description provided for @agendaCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} na agenda'**
  String agendaCount(int count);

  /// No description provided for @focus.
  ///
  /// In pt, this message translates to:
  /// **'Foco'**
  String get focus;

  /// No description provided for @focusDone.
  ///
  /// In pt, this message translates to:
  /// **'Foco concluído! Hora da pausa ☕'**
  String get focusDone;

  /// No description provided for @breakDone.
  ///
  /// In pt, this message translates to:
  /// **'Pausa concluída. Bora pro próximo ciclo?'**
  String get breakDone;

  /// No description provided for @breakLabel.
  ///
  /// In pt, this message translates to:
  /// **'PAUSA'**
  String get breakLabel;

  /// No description provided for @focusCycles.
  ///
  /// In pt, this message translates to:
  /// **'FOCO • {cycles} ciclos'**
  String focusCycles(int cycles);

  /// No description provided for @breakTip.
  ///
  /// In pt, this message translates to:
  /// **'Respire, alongue, beba água.'**
  String get breakTip;

  /// No description provided for @focusTip.
  ///
  /// In pt, this message translates to:
  /// **'Dica da IA: 1 tarefa, celular longe, 25 min direto.'**
  String get focusTip;

  /// No description provided for @pause.
  ///
  /// In pt, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @reset.
  ///
  /// In pt, this message translates to:
  /// **'Resetar'**
  String get reset;

  /// No description provided for @taskCreatedByAi.
  ///
  /// In pt, this message translates to:
  /// **'Criada: \"{title}\" • {steps, plural, =1{1 passo sugerido} other{{steps} passos sugeridos}} pela IA'**
  String taskCreatedByAi(String title, int steps);

  /// No description provided for @errorSaving.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar: {error}'**
  String errorSaving(String error);

  /// No description provided for @errorRemoving.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao remover: {error}'**
  String errorRemoving(String error);

  /// No description provided for @errorDeleting.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao apagar: {error}'**
  String errorDeleting(String error);

  /// No description provided for @errorUpdatingTask.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao atualizar tarefa: {error}'**
  String errorUpdatingTask(String error);

  /// No description provided for @notificationChannelName.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes de Tarefas'**
  String get notificationChannelName;

  /// No description provided for @notificationChannelDesc.
  ///
  /// In pt, this message translates to:
  /// **'Alertas de tarefas agendadas'**
  String get notificationChannelDesc;

  /// No description provided for @updateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar. Tente de novo.'**
  String get updateFailed;

  /// No description provided for @searchTasksHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar tarefa ou #projeto…'**
  String get searchTasksHint;

  /// No description provided for @filterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get filterAll;

  /// No description provided for @filterMyDay.
  ///
  /// In pt, this message translates to:
  /// **'Meu Dia'**
  String get filterMyDay;

  /// No description provided for @filterUpcoming.
  ///
  /// In pt, this message translates to:
  /// **'Próximas'**
  String get filterUpcoming;

  /// No description provided for @filterDone.
  ///
  /// In pt, this message translates to:
  /// **'Feitas'**
  String get filterDone;

  /// No description provided for @emptyDone.
  ///
  /// In pt, this message translates to:
  /// **'Nada concluído ainda — complete a primeira e volte aqui.'**
  String get emptyDone;

  /// No description provided for @emptyTasks.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma tarefa aqui.\nToque no botão abaixo para adicionar com linguagem natural.'**
  String get emptyTasks;

  /// No description provided for @completedLabel.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get completedLabel;

  /// No description provided for @markAsCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Marcar como concluída'**
  String get markAsCompleted;

  /// No description provided for @projectOptional.
  ///
  /// In pt, this message translates to:
  /// **'Projeto (opcional)'**
  String get projectOptional;

  /// No description provided for @projectHint.
  ///
  /// In pt, this message translates to:
  /// **'#projeto — casa, trabalho…'**
  String get projectHint;

  /// No description provided for @aiSuggestedSteps.
  ///
  /// In pt, this message translates to:
  /// **'Passos sugeridos pela IA local'**
  String get aiSuggestedSteps;

  /// No description provided for @signInFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar. Tente novamente.'**
  String get signInFailed;

  /// No description provided for @loginToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get loginToday;

  /// No description provided for @loginSample1.
  ///
  /// In pt, this message translates to:
  /// **'Pagar conta de luz'**
  String get loginSample1;

  /// No description provided for @loginSample2.
  ///
  /// In pt, this message translates to:
  /// **'Reunião 9h'**
  String get loginSample2;

  /// No description provided for @loginSample3.
  ///
  /// In pt, this message translates to:
  /// **'Academia 18h'**
  String get loginSample3;

  /// No description provided for @loginProgress.
  ///
  /// In pt, this message translates to:
  /// **'2 de 3 concluídas'**
  String get loginProgress;

  /// No description provided for @loginBadgeTime.
  ///
  /// In pt, this message translates to:
  /// **'Seg 9:00'**
  String get loginBadgeTime;

  /// No description provided for @loginBadgeMeeting.
  ///
  /// In pt, this message translates to:
  /// **'Reunião'**
  String get loginBadgeMeeting;

  /// No description provided for @loginBadgeReminder.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete'**
  String get loginBadgeReminder;

  /// No description provided for @loginBadgeGym.
  ///
  /// In pt, this message translates to:
  /// **'Academia 18h'**
  String get loginBadgeGym;

  /// No description provided for @welcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta 👋'**
  String get welcomeBack;

  /// No description provided for @signInToSee.
  ///
  /// In pt, this message translates to:
  /// **'Entre para ver suas tarefas de hoje.'**
  String get signInToSee;

  /// No description provided for @notesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Anotações'**
  String get notesTitle;

  /// No description provided for @searchNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar nas notas…'**
  String get searchNotesHint;

  /// No description provided for @noNotesFor.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma nota para \"{query}\".'**
  String noNotesFor(String query);

  /// No description provided for @createNote.
  ///
  /// In pt, this message translates to:
  /// **'Criar nota'**
  String get createNote;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @errorDeletingNote.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao deletar nota: {error}'**
  String errorDeletingNote(String error);

  /// No description provided for @agoDays.
  ///
  /// In pt, this message translates to:
  /// **'há {count}d'**
  String agoDays(int count);

  /// No description provided for @agoHours.
  ///
  /// In pt, this message translates to:
  /// **'há {count}h'**
  String agoHours(int count);

  /// No description provided for @agoMinutes.
  ///
  /// In pt, this message translates to:
  /// **'há {count}min'**
  String agoMinutes(int count);

  /// No description provided for @justNow.
  ///
  /// In pt, this message translates to:
  /// **'agora mesmo'**
  String get justNow;

  /// No description provided for @saveNoteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao salvar a nota. Tente novamente.'**
  String get saveNoteFailed;

  /// No description provided for @agoDaysLong.
  ///
  /// In pt, this message translates to:
  /// **'há {count, plural, =1{1 dia} other{{count} dias}}'**
  String agoDaysLong(int count);

  /// No description provided for @agoHoursLong.
  ///
  /// In pt, this message translates to:
  /// **'há {count, plural, =1{1 hora} other{{count} horas}}'**
  String agoHoursLong(int count);

  /// No description provided for @agoMinutesLong.
  ///
  /// In pt, this message translates to:
  /// **'há {count, plural, =1{1 minuto} other{{count} minutos}}'**
  String agoMinutesLong(int count);

  /// No description provided for @lastEdit.
  ///
  /// In pt, this message translates to:
  /// **'Última edição: {when}'**
  String lastEdit(String when);

  /// No description provided for @updateTaskFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falha ao atualizar.'**
  String get updateTaskFailed;

  /// No description provided for @supportEmailSubject.
  ///
  /// In pt, this message translates to:
  /// **'[Tarefas App] Suporte & Feedback'**
  String get supportEmailSubject;

  /// No description provided for @emailOpenFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o app de e-mail. Contato: hendrilmendes2015@gmail.com'**
  String get emailOpenFailed;

  /// No description provided for @userFallback.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get userFallback;

  /// No description provided for @alerts.
  ///
  /// In pt, this message translates to:
  /// **'Alertas'**
  String get alerts;

  /// No description provided for @sendEmail.
  ///
  /// In pt, this message translates to:
  /// **'Enviar e-mail'**
  String get sendEmail;

  /// No description provided for @contactDeveloper.
  ///
  /// In pt, this message translates to:
  /// **'Fale com o desenvolvedor'**
  String get contactDeveloper;

  /// No description provided for @steps.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 passo} other{{count} passos}}'**
  String steps(int count);

  /// No description provided for @tabAgenda.
  ///
  /// In pt, this message translates to:
  /// **'Agenda'**
  String get tabAgenda;

  /// No description provided for @assistantBadge.
  ///
  /// In pt, this message translates to:
  /// **'ASSISTENTE LOCAL'**
  String get assistantBadge;

  /// No description provided for @focusNow.
  ///
  /// In pt, this message translates to:
  /// **'FOCO AGORA'**
  String get focusNow;

  /// No description provided for @pomodoro.
  ///
  /// In pt, this message translates to:
  /// **'Pomodoro'**
  String get pomodoro;

  /// No description provided for @quickAddEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Digite a tarefa — ex.: Amanhã 15h pagar conta #casa'**
  String get quickAddEmpty;

  /// No description provided for @quickAddTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova tarefa inteligente'**
  String get quickAddTitle;

  /// No description provided for @quickAddHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Segunda 9h reunião #trabalho !p1'**
  String get quickAddHint;

  /// No description provided for @quickAddTip.
  ///
  /// In pt, this message translates to:
  /// **'Dica: use \"amanhã 15h\", \"#projeto\", \"!p1\" e a IA entende sozinha.'**
  String get quickAddTip;

  /// No description provided for @noDateSuggestToday.
  ///
  /// In pt, this message translates to:
  /// **'Sem data — sugerir hoje'**
  String get noDateSuggestToday;

  /// No description provided for @suggestedSteps.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 passo sugerido} other{{count} passos sugeridos}}'**
  String suggestedSteps(int count);

  /// No description provided for @priorityColon.
  ///
  /// In pt, this message translates to:
  /// **'Prioridade:'**
  String get priorityColon;

  /// No description provided for @releaseNotesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma nota de versão encontrada para esta versão.'**
  String get releaseNotesEmpty;

  /// No description provided for @releaseNotesError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar as notas da versão. Código: {code}'**
  String releaseNotesError(int code);

  /// No description provided for @releaseNotesConnection.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar. Verifique sua conexão com a internet.'**
  String get releaseNotesConnection;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageSub.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o idioma do app'**
  String get languageSub;

  /// No description provided for @languageAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático (sistema)'**
  String get languageAuto;

  /// No description provided for @stepsShopping.
  ///
  /// In pt, this message translates to:
  /// **'Listar itens prioritários|Verificar despensa e geladeira|Definir orçamento máximo|Ir ao supermercado ou feira'**
  String get stepsShopping;

  /// No description provided for @stepsMeeting.
  ///
  /// In pt, this message translates to:
  /// **'Definir pauta e objetivo|Reunir links e apresentações|Enviar convite/lembrete aos participantes|Registrar ata e próximos passos'**
  String get stepsMeeting;

  /// No description provided for @stepsCoding.
  ///
  /// In pt, this message translates to:
  /// **'Entender requisito e edge cases|Criar branch e escrever código|Testar localmente cenários de erro|Abrir PR e solicitar review'**
  String get stepsCoding;

  /// No description provided for @stepsFinance.
  ///
  /// In pt, this message translates to:
  /// **'Revisar extrato bancário|Categorizar receitas e despesas|Identificar gastos supérfluos|Atualizar planilha ou app financeiro'**
  String get stepsFinance;

  /// No description provided for @stepsHealth.
  ///
  /// In pt, this message translates to:
  /// **'Marcar consulta ou exame|Separar exames anteriores|Anotar dúvidas para o médico|Confirmar horário e trajeto'**
  String get stepsHealth;

  /// No description provided for @noteTotalDetected.
  ///
  /// In pt, this message translates to:
  /// **'Total detectado:'**
  String get noteTotalDetected;

  /// No description provided for @noteValuesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 valor} other{{count} valores}}'**
  String noteValuesCount(int count);

  /// No description provided for @insertTotalInNote.
  ///
  /// In pt, this message translates to:
  /// **'Inserir total na nota'**
  String get insertTotalInNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
