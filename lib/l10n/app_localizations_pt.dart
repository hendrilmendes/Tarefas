// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Tá na Lista';

  @override
  String get home => 'Tarefas';

  @override
  String get notes => 'Anotações';

  @override
  String get settings => 'Ajustes';

  @override
  String get googleLogin => 'Login com Google';

  @override
  String get ok => 'OK';

  @override
  String get newTask => 'Nova Tarefa';

  @override
  String get newNote => 'Nova Anotação';

  @override
  String get saveNote => 'Anotação salva com sucesso!';

  @override
  String get errosaveNote => 'Erro ao salvar anotação.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Apagar';

  @override
  String get save => 'Salvar';

  @override
  String get notesDetails => 'Detalhes da Anotação';

  @override
  String get inputTask => 'Digite sua tarefa';

  @override
  String get inputNote => 'Digite sua anotação';

  @override
  String get errorLoadNotes => 'Erro ao carregar anotações';

  @override
  String get noTask => 'Nenhuma tarefa encontrada';

  @override
  String get noNotes => 'Nenhuma anotação encontrada';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String get confirmDeleteNote =>
      'Tem certeza de que deseja excluir esta anotação?';

  @override
  String get about => 'Sobre';

  @override
  String get copyright => 'Todos os direitos reservados';

  @override
  String get appDesc => 'Organize suas tarefas e anotações diárias.';

  @override
  String get version => 'Versão';

  @override
  String get privacy => 'Política de Privacidade';

  @override
  String get privacySub => 'Termos que garantem a sua privacidade';

  @override
  String get sourceCode => 'Código Fonte';

  @override
  String get sourceCodeSub => 'Projeto disponível no GitHub';

  @override
  String get openSource => 'Licenças de Código Aberto';

  @override
  String get openSourceSub => 'Softwares de terceiros usados no app';

  @override
  String get interface => 'Interface';

  @override
  String get others => 'Outros';

  @override
  String get theme => 'Tema';

  @override
  String get themeSelect => 'Escolha o Tema';

  @override
  String get darkMode => 'Escuro';

  @override
  String get lightMode => 'Claro';

  @override
  String get systemMode => 'Sistema';

  @override
  String get dynamicColors => 'Dynamic Colors';

  @override
  String get dynamicColorsSub =>
      'Proporciona uma interface agradável de acordo com o seu papel de parede';

  @override
  String get update => 'Atualizações';

  @override
  String get updateSub => 'Procurar por novas versões do app';

  @override
  String get support => 'Suporte';

  @override
  String get supportSub => 'Encontrou um bug ou deseja sugerir algo?';

  @override
  String get review => 'Avalie o App';

  @override
  String get reviewSub => 'Faça uma avaliação na loja de apps';

  @override
  String get aboutSub => 'Um pouco mais sobre o app';

  @override
  String get newUpdate => 'Nova versão disponível';

  @override
  String get news => 'Novidades:';

  @override
  String get after => 'DEPOIS';

  @override
  String get download => 'BAIXAR';

  @override
  String get noUpdate => 'Nenhuma atualização disponível';

  @override
  String get noUpdateSub => 'Você já está com a última versão do app';

  @override
  String get pendants => 'Pendentes';

  @override
  String get completed => 'Concluídas';

  @override
  String get dateTime => 'Selecione a data e hora';

  @override
  String get taskDetails => 'Detalhes da Tarefa';

  @override
  String get notificationTask => 'Não se esqueça';

  @override
  String get error => 'Erro';

  @override
  String get inputDateError => 'A data e hora são necessárias';

  @override
  String get inputTaskError => 'Não e possível adicionar uma tarefa em branco';

  @override
  String get inputNoteError => 'Não e possível salvar uma anotação em branco';

  @override
  String get notification => 'Notificações';

  @override
  String get notificationSub => 'Notificações sobre suas tarefas';

  @override
  String get confirmDeleteTask => 'Deseja realmente apagar a tarefa?';

  @override
  String get share => 'Compartilhar';

  @override
  String get alreadyReviewed => 'Você já avaliou o app';

  @override
  String get dateTitle => 'Data da Tarefa';

  @override
  String get noDate => 'Sem Agendamento';

  @override
  String get taskTitle => 'Título da Tarefa';

  @override
  String get errorUpdate => 'Não foi possível verificar atualizações.';

  @override
  String get loading => 'Carregando...';

  @override
  String get loginError => 'Erro no login';

  @override
  String get personalization => 'Personalização';

  @override
  String get personalizationSub => 'Personalize o app da forma que quiser';

  @override
  String get color => 'Cor';

  @override
  String get accentColor => 'Cor de Destaque';

  @override
  String get dynamicColorsEnabledWarning => 'O Dynamic Colors esta ativado';

  @override
  String get information => 'Informações';

  @override
  String get displayMode => 'Modo de Exibição';

  @override
  String get addTasks => 'Toque no botão + para criar sua primeira tarefa';

  @override
  String get addNotes => 'Toque no botão + para criar sua primeira nota';

  @override
  String get acceptTerms => 'Ao continuar, você concorda com a nossa ';

  @override
  String get welcomeMessageTitle => 'Organize seu dia,';

  @override
  String get welcomeMessageSub => 'alcance seus objetivos.';

  @override
  String get logout => 'Sair';

  @override
  String get logoutConfirm => 'Desconectar';

  @override
  String get logoutConfirmSub =>
      'Você tem certeza que quer desconectar do app?';

  @override
  String get greetingNight => 'Boa madrugada';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name 👋';
  }

  @override
  String get you => 'você';

  @override
  String get briefingEmpty =>
      'Você está com a agenda livre. Que tal planejar o dia em 3 metas?';

  @override
  String briefingOverdueToday(int overdue, int today) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue atrasadas',
      one: '1 atrasada',
    );
    return 'Você tem $_temp0 e $today para hoje. Vamos limpar as atrasadas primeiro.';
  }

  @override
  String briefingOverdue(int overdue) {
    String _temp0 = intl.Intl.pluralLogic(
      overdue,
      locale: localeName,
      other: '$overdue tarefas atrasadas',
      one: '1 tarefa atrasada',
    );
    return 'Você tem $_temp0. Recomendo reagendar ou concluir agora.';
  }

  @override
  String briefingToday(int today) {
    String _temp0 = intl.Intl.pluralLogic(
      today,
      locale: localeName,
      other: '$today tarefas',
      one: '1 tarefa',
    );
    return 'Hoje você tem $_temp0. Bom ritmo — foque na primeira abaixo.';
  }

  @override
  String briefingPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendentes',
      one: '1 pendente',
    );
    return 'Nada para hoje, mas há $_temp0 à frente. Que tal adiantar uma?';
  }

  @override
  String get briefingAllDone =>
      'Tudo concluído. Dia limpo — aproveite para revisar as notas.';

  @override
  String suggestionFocus(String title, String when) {
    return 'Sugestão: comece por \"$title\" ($when). Divida em passos de 10 min se travar.';
  }

  @override
  String get suggestionCreate =>
      'Sugestão: crie 3 tarefas com horário — ex.: \"Amanhã 9h academia #saude\".';

  @override
  String get whenNoTime => 'sem horário';

  @override
  String get whenOverdue => 'atrasada';

  @override
  String whenToday(String time) {
    return 'hoje às $time';
  }

  @override
  String get whenTomorrow => 'amanhã';

  @override
  String whenInDays(int days) {
    return 'em $days dias';
  }

  @override
  String get stepsTravel =>
      'Definir datas e orçamento|Reservar transporte e hospedagem|Fazer checklist de malas|Confirmar documentos';

  @override
  String get stepsStudy =>
      'Separar material em 3 blocos|Estudar bloco 1 (25 min foco)|Revisar com resumos|Fazer questões/exercícios';

  @override
  String get stepsClean =>
      'Escolher 1 cômodo|Separar o que sai / fica|Limpar em 15 min|Guardar e fotografar o resultado';

  @override
  String get stepsProject =>
      'Definir objetivo em 1 frase|Rascunhar estrutura|Preencher conteúdo|Revisar e enviar';

  @override
  String get stepsWorkout =>
      'Separar roupa + água|Aquecer 5 min|Treino principal 20 min|Alongar e registrar';

  @override
  String get stepsBill =>
      'Conferir valor e vencimento|Pagar no app/banco|Salvar comprovante';

  @override
  String get stepsGeneric =>
      'Definir o primeiro passo de 5 min|Executar sem interrupção|Revisar e marcar como feito';

  @override
  String slotToday(String time) {
    return 'Hoje às $time parece livre';
  }

  @override
  String get slotTomorrow => 'Amanhã às 09:00 parece ideal';

  @override
  String get priorityUrgent => 'Urgente';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get priorityMedium => 'Média';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priority => 'Prioridade';

  @override
  String get overdue => 'Atrasadas';

  @override
  String get today => 'Hoje';

  @override
  String get tomorrow => 'Amanhã';

  @override
  String get noDateGroup => 'Sem data';

  @override
  String get agenda => 'Agenda';

  @override
  String get agendaFreeTitle => 'Agenda livre por aqui';

  @override
  String agendaFreeBody(String tip) {
    return 'Nada nos próximos 14 dias.\n$tip.';
  }

  @override
  String agendaCount(int count) {
    return '$count na agenda';
  }

  @override
  String get focus => 'Foco';

  @override
  String get focusDone => 'Foco concluído! Hora da pausa ☕';

  @override
  String get breakDone => 'Pausa concluída. Bora pro próximo ciclo?';

  @override
  String get breakLabel => 'PAUSA';

  @override
  String focusCycles(int cycles) {
    return 'FOCO • $cycles ciclos';
  }

  @override
  String get breakTip => 'Respire, alongue, beba água.';

  @override
  String get focusTip => 'Dica da IA: 1 tarefa, celular longe, 25 min direto.';

  @override
  String get pause => 'Pausar';

  @override
  String get start => 'Começar';

  @override
  String get reset => 'Resetar';

  @override
  String taskCreatedByAi(String title, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps passos sugeridos',
      one: '1 passo sugerido',
    );
    return 'Criada: \"$title\" • $_temp0 pela IA';
  }

  @override
  String errorSaving(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String errorRemoving(String error) {
    return 'Erro ao remover: $error';
  }

  @override
  String errorDeleting(String error) {
    return 'Erro ao apagar: $error';
  }

  @override
  String errorUpdatingTask(String error) {
    return 'Erro ao atualizar tarefa: $error';
  }

  @override
  String get notificationChannelName => 'Lembretes de Tarefas';

  @override
  String get notificationChannelDesc => 'Alertas de tarefas agendadas';

  @override
  String get updateFailed => 'Falha ao atualizar. Tente de novo.';

  @override
  String get searchTasksHint => 'Buscar tarefa ou #projeto…';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterMyDay => 'Meu Dia';

  @override
  String get filterUpcoming => 'Próximas';

  @override
  String get filterDone => 'Feitas';

  @override
  String get emptyDone =>
      'Nada concluído ainda — complete a primeira e volte aqui.';

  @override
  String get emptyTasks =>
      'Nenhuma tarefa aqui.\nToque no botão abaixo para adicionar com linguagem natural.';

  @override
  String get completedLabel => 'Concluída';

  @override
  String get markAsCompleted => 'Marcar como concluída';

  @override
  String get projectOptional => 'Projeto (opcional)';

  @override
  String get projectHint => '#projeto — casa, trabalho…';

  @override
  String get aiSuggestedSteps => 'Passos sugeridos pela IA local';

  @override
  String get signInFailed => 'Não foi possível entrar. Tente novamente.';

  @override
  String get loginToday => 'Hoje';

  @override
  String get loginSample1 => 'Pagar conta de luz';

  @override
  String get loginSample2 => 'Reunião 9h';

  @override
  String get loginSample3 => 'Academia 18h';

  @override
  String get loginProgress => '2 de 3 concluídas';

  @override
  String get loginBadgeTime => 'Seg 9:00';

  @override
  String get loginBadgeMeeting => 'Reunião';

  @override
  String get loginBadgeReminder => 'Lembrete';

  @override
  String get loginBadgeGym => 'Academia 18h';

  @override
  String get welcomeBack => 'Bem-vindo de volta 👋';

  @override
  String get signInToSee => 'Entre para ver suas tarefas de hoje.';

  @override
  String get notesTitle => 'Anotações';

  @override
  String get searchNotesHint => 'Buscar nas notas…';

  @override
  String noNotesFor(String query) {
    return 'Nenhuma nota para \"$query\".';
  }

  @override
  String get createNote => 'Criar nota';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String errorDeletingNote(String error) {
    return 'Erro ao deletar nota: $error';
  }

  @override
  String agoDays(int count) {
    return 'há ${count}d';
  }

  @override
  String agoHours(int count) {
    return 'há ${count}h';
  }

  @override
  String agoMinutes(int count) {
    return 'há ${count}min';
  }

  @override
  String get justNow => 'agora mesmo';

  @override
  String get saveNoteFailed => 'Falha ao salvar a nota. Tente novamente.';

  @override
  String agoDaysLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return 'há $_temp0';
  }

  @override
  String agoHoursLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return 'há $_temp0';
  }

  @override
  String agoMinutesLong(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return 'há $_temp0';
  }

  @override
  String lastEdit(String when) {
    return 'Última edição: $when';
  }

  @override
  String get updateTaskFailed => 'Falha ao atualizar.';

  @override
  String get supportEmailSubject => '[Tarefas App] Suporte & Feedback';

  @override
  String get emailOpenFailed =>
      'Não foi possível abrir o app de e-mail. Contato: hendrilmendes2015@gmail.com';

  @override
  String get userFallback => 'Usuário';

  @override
  String get alerts => 'Alertas';

  @override
  String get sendEmail => 'Enviar e-mail';

  @override
  String get contactDeveloper => 'Fale com o desenvolvedor';

  @override
  String steps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos',
      one: '1 passo',
    );
    return '$_temp0';
  }

  @override
  String get tabAgenda => 'Agenda';

  @override
  String get assistantBadge => 'ASSISTENTE LOCAL';

  @override
  String get focusNow => 'FOCO AGORA';

  @override
  String get pomodoro => 'Pomodoro';

  @override
  String get quickAddEmpty =>
      'Digite a tarefa — ex.: Amanhã 15h pagar conta #casa';

  @override
  String get quickAddTitle => 'Nova tarefa inteligente';

  @override
  String get quickAddHint => 'Ex.: Segunda 9h reunião #trabalho !p1';

  @override
  String get quickAddTip =>
      'Dica: use \"amanhã 15h\", \"#projeto\", \"!p1\" e a IA entende sozinha.';

  @override
  String get noDateSuggestToday => 'Sem data — sugerir hoje';

  @override
  String suggestedSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos sugeridos',
      one: '1 passo sugerido',
    );
    return '$_temp0';
  }

  @override
  String get priorityColon => 'Prioridade:';

  @override
  String get releaseNotesEmpty =>
      'Nenhuma nota de versão encontrada para esta versão.';

  @override
  String releaseNotesError(int code) {
    return 'Erro ao carregar as notas da versão. Código: $code';
  }

  @override
  String get releaseNotesConnection =>
      'Erro ao carregar. Verifique sua conexão com a internet.';

  @override
  String get language => 'Idioma';

  @override
  String get languageSub => 'Escolha o idioma do app';

  @override
  String get languageAuto => 'Automático (sistema)';

  @override
  String get stepsShopping =>
      'Listar itens prioritários|Verificar despensa e geladeira|Definir orçamento máximo|Ir ao supermercado ou feira';

  @override
  String get stepsMeeting =>
      'Definir pauta e objetivo|Reunir links e apresentações|Enviar convite/lembrete aos participantes|Registrar ata e próximos passos';

  @override
  String get stepsCoding =>
      'Entender requisito e edge cases|Criar branch e escrever código|Testar localmente cenários de erro|Abrir PR e solicitar review';

  @override
  String get stepsFinance =>
      'Revisar extrato bancário|Categorizar receitas e despesas|Identificar gastos supérfluos|Atualizar planilha ou app financeiro';

  @override
  String get stepsHealth =>
      'Marcar consulta ou exame|Separar exames anteriores|Anotar dúvidas para o médico|Confirmar horário e trajeto';

  @override
  String get noteTotalDetected => 'Total detectado:';

  @override
  String noteValuesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valores',
      one: '1 valor',
    );
    return '$_temp0';
  }

  @override
  String get insertTotalInNote => 'Inserir total na nota';
}
