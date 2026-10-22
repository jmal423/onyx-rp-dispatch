const locale = {
  cd_dispatch_small_title: "Sem ocorrências na central",
  cd_dispatch_small_previous: "Anterior",
  cd_dispatch_small_next: "Seguinte",
  cd_dispatch_small_respond: "Responder",
  cd_dispatch_small_mode: "Clique com o botão direito para sair do modo de mover.",

  cd_dispatch_main_show_refresh_bar: "Mostrar",
  cd_dispatch_main_hide_refresh_bar: "Ocultar",
  cd_dispatch_main_refresh: "Atualizar marcadores",
  cd_dispatch_main_close_refresh_bar: "Fechar",
  cd_dispatch_main_refresh_last: "Última atualização",

  cd_dispatch_main_units_responding: "unidade(s) a responder",

  cd_dispatch_unit_list: "Lista de unidades",

  cd_dispatch_main_dropdown_respond: "Responder à ocorrência",
  cd_dispatch_main_dropdown_remove_response: "Retirar resposta à ocorrência",
  cd_dispatch_main_dropdown_remove_notification: "Remover esta ocorrência",
  cd_dispatch_main_dropdown_remove_all: "Remover todas as ocorrências",
  cd_dispatch_main_dropdown_assign_all: "Atribuir todas as unidades à ocorrência",

  cd_dispatch_main_modal_title: "Definições do dispatch",
  cd_dispatch_main_modal_autodel: "Remover automaticamente após",
  cd_dispatch_main_modal_autodel_desc:"Tempo até à remoção automática da ocorrência (em minutos, 1–60)",
  cd_dispatch_main_modal_set_callsign:"Alterar callsign",
  cd_dispatch_main_modal_set_callsign_help:"Este callsign será visível para todos os utilizadores do dispatch",
  cd_dispatch_main_modal_close: "Fechar",
  cd_dispatch_main_modal_save: "Guardar alterações",
  cd_dispatch_main_modal_sound_control: "Som",
  cd_dispatch_main_modal_mute_sounds: " Silenciar sons",
  cd_dispatch_main_modal_mute_sounds_description: "Esta opção silencia os sons de pânico e das notificações",
  cd_dispatch_main_modal_enable_dispatcher: "Ativar modo de operador?",
  cd_dispatch_main_modal_toggle_button:"Alternar modo de operador",
  cd_dispatch_main_modal_dispatcher_status: "O modo de operador está atualmente",
  cd_dispatch_main_modal_dispatcher_status_enabled: "ativo.",
  cd_dispatch_main_modal_dispatcher_status_disabled: "inativo.",

  cd_dispatch_unit_dropdown_gps: "Marcar localização no GPS",
  cd_dispatch_unit_join_radio:"Entrar no canal de rádio",
  cd_dispatch_unit_leave_radio:"Sair do canal de rádio",

  cd_dispatch_toggle_voice_on: "Ativar voz",
  cd_dispatch_toggle_voice_off: "Desativar voz",
  cd_dispatch_revert_map: "Repor",

  cd_dispatch_notification_panel: "Painel de ocorrências",

  cd_dispatch_settings_status: "Estado",
  cd_dispatch_settings_status_help: "Selecione o seu estado atual.",

  cd_dispatch_units_notification: "Nenhuma unidade a responder",

  cd_dispatch_tamper_message: "Os valores foram alterados?",
  cd_dispatch_callsign_message: "O callsign tem de ter menos de 16 caracteres.",

};

let statusMessages = [
  {name:"Disponível", color:"#539D1B"}, // The status will default to the first one in the list
  {name:"Indisponível", color:"#F05B56"},
  {name:"A tratar de uma ocorrência", color:"#E46211"},
  {name:"Em formação", color:"#009DE0"},
  {name:"À paisana", color:"#2E570F"},
]

moment.defineLocale("pt", {
  months: "janeiro_fevereiro_março_abril_maio_junho_julho_agosto_setembro_outubro_novembro_dezembro".split("_"),
  monthsShort: "jan_fev_mar_abr_mai_jun_jul_ago_set_out_nov_dez".split("_"),
  weekdays: "domingo_segunda-feira_terça-feira_quarta-feira_quinta-feira_sexta-feira_sábado".split("_"),
  weekdaysShort: "dom_seg_ter_qua_qui_sex_sáb".split("_"),
  weekdaysMin: "do_2ª_3ª_4ª_5ª_6ª_sá".split("_"),
  longDateFormat: {
    LT: "HH:mm",
    LTS: "HH:mm:ss",
    L: "DD/MM/YYYY",
    LL: "D [de] MMMM [de] YYYY",
    LLL: "D [de] MMMM [de] YYYY [às] HH:mm",
    LLLL: "dddd, D [de] MMMM [de] YYYY [às] HH:mm",
  },
  calendar: {
    sameDay: "[hoje às] LT",
    nextDay: "[amanhã às] LT",
    nextWeek: "dddd [às] LT",
    lastDay: "[ontem às] LT",
    lastWeek: "[no] dddd [passado às] LT",
    sameElse: "L",
  },
  relativeTime: {
    future: "daqui a %s",
    past: "há %s",
    s: "alguns segundos",
    ss: "%d segundos",
    m: "um minuto",
    mm: "%d minutos",
    h: "uma hora",
    hh: "%d horas",
    d: "um dia",
    dd: "%d dias",
    w: "uma semana",
    ww: "%d semanas",
    M: "um mês",
    MM: "%d meses",
    y: "um ano",
    yy: "%d anos",
  },
  dayOfMonthOrdinalParse: /\d{1,2}º/,
  ordinal: "%dº",
});
moment.locale("pt"); // Formata o tempo apresentado no painel pequeno em português.

// Possible locales v
// en,af,ar-dz,ar-kw,ar-ly,ar-ma,ar-sa,ar-tn,ar,az,be,bg,bm,bn-bd,bn,bo,br,bs,ca,cs,cv,cy,da,de-at,de-ch,de,dv,el,en-au,en-ca,en-gb,en-ie,en-il,en-in,en-nz,en-sg,eo,es-do,es-mx,es-us,es,et,eu,fa,fi,fil,fo,fr-ca,fr-ch,fr,fy,ga,gd,gl,gom-deva,gom-latn,gu,he,hi,hr,hu,hy-am,id,is,it-ch,it,ja,jv,ka,kk,km,kn,ko,ku,ky,lb,lo,lt,lv,me,mi,mk,ml,mn,mr,ms-my,ms,mt,my,nb,ne,nl-be,nl,nn,oc-lnc,pa-in,pl,pt-br,pt,ro,ru,sd,se,si,sk,sl,sq,sr-cyrl,sr,ss,sv,sw,ta,te,tet,tg,th,tk,tl-ph,tlh,tr,tzl,tzm-latn,tzm,ug-cn,uk,ur,uz-latn,uz,vi,x-pseudo,yo,zh-cn,zh-hk,zh-mo,zh-tw
