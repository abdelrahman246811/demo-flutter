import 'package:flutter/material.dart';

// Steinbruch Class
class Steinbruch {
  final int? s_id;
  final String s_name;
  final double s_menge;
  final double s_korngroesse;
  final String s_asbestAnalyse;
  final double s_dichte;
  final String s_transport;

  Steinbruch({
    this.s_id,
    required this.s_name,
    required this.s_menge,
    required this.s_korngroesse,
    required this.s_asbestAnalyse,
    required this.s_dichte,
    required this.s_transport,
  });

  Map<String, Object?> toMap() {
    return {
      's_id': s_id,
      's_name': s_name,
      's_menge': s_menge,
      's_korngroesse': s_korngroesse,
      's_asbest_analyse': s_asbestAnalyse,
      's_dichte': s_dichte,
      's_transport': s_transport,
    };
  }

  @override
  String toString() {
    return 'Steinbruch{s_id: $s_id, s_name: $s_name, s_menge: $s_menge, s_korngroesse: $s_korngroesse, s_asbestAnalyse: $s_asbestAnalyse, s_dichte: $s_dichte, s_transport: $s_transport}';
  }
}

// Vormahlung Class
class Vormahlung {
  final int? v_id;
  final int steinbruchId;
  final String v_charge;
  final bool v_erledigt;
  final String v_muehleTyp;
  final double v_mahlDauer;
  final String v_grad;
  final double v_dichte;
  final double v_feinheit;

  Vormahlung({
    this.v_id,
    required this.steinbruchId,
    required this.v_charge,
    required this.v_erledigt,
    required this.v_muehleTyp,
    required this.v_mahlDauer,
    required this.v_grad,
    required this.v_dichte,
    required this.v_feinheit,
  });

  Map<String, Object?> toMap() {
    return {
      'v_id': v_id,
      'steinbruch_id': steinbruchId,
      'v_charge': v_charge,
      'v_erledigt': v_erledigt ? 1 : 0,
      'v_muehle_typ': v_muehleTyp,
      'v_mahl_dauer': v_mahlDauer,
      'v_grad': v_grad,
      'v_dichte': v_dichte,
      'v_feinheit': v_feinheit,
    };
  }

  @override
  String toString() {
    return 'Vormahlung{v_id: $v_id, steinbruchId: $steinbruchId, v_charge: $v_charge, v_erledigt: $v_erledigt, v_muehleTyp: $v_muehleTyp, v_mahlDauer: $v_mahlDauer, v_grad: $v_grad, v_dichte: $v_dichte, v_feinheit: $v_feinheit}';
  }
}

// Ofen Class
class Ofen {
  final int? o_id;
  final int vormahlungId;
  final String o_charge;
  final String o_info;
  final double o_durchsatz;
  final double o_neigung;
  final double o_rotation;
  final double o_heiztemperatur;
  final double o_luftvolumen;
  final int o_faesser;
  final double o_gluehverlust;

  Ofen({
    this.o_id,
    required this.vormahlungId,
    required this.o_charge,
    required this.o_info,
    required this.o_durchsatz,
    required this.o_neigung,
    required this.o_rotation,
    required this.o_heiztemperatur,
    required this.o_luftvolumen,
    required this.o_faesser,
    required this.o_gluehverlust,
  });

  Map<String, Object?> toMap() {
    return {
      'o_id': o_id,
      'vormahlung_id': vormahlungId,
      'o_charge': o_charge,
      'o_info': o_info,
      'o_durchsatz': o_durchsatz,
      'o_neigung': o_neigung,
      'o_rotation': o_rotation,
      'o_heiztemperatur': o_heiztemperatur,
      'o_luftvolumen': o_luftvolumen,
      'o_faesser': o_faesser,
      'o_gluehverlust': o_gluehverlust,
    };
  }

  @override
  String toString() {
    return 'Ofen{o_id: $o_id, vormahlungId: $vormahlungId, o_charge: $o_charge, o_info: $o_info, o_durchsatz: $o_durchsatz, o_neigung: $o_neigung, o_rotation: $o_rotation, o_heiztemperatur: $o_heiztemperatur, o_luftvolumen: $o_luftvolumen, o_faesser: $o_faesser, o_gluehverlust: $o_gluehverlust}';
  }
}

// MaterialEigenschaften Class
class MaterialEigenschaften {
  final int? me_id;
  final int ofenId;
  final String me_charge;
  final double me_dichte;
  final double me_feinheit;
  final double me_dca;
  final String me_xrd;

  MaterialEigenschaften({
    this.me_id,
    required this.ofenId,
    required this.me_charge,
    required this.me_dichte,
    required this.me_feinheit,
    required this.me_dca,
    required this.me_xrd,
  });

  Map<String, Object?> toMap() {
    return {
      'me_id': me_id,
      'ofen_id': ofenId,
      'me_charge': me_charge,
      'me_dichte': me_dichte,
      'me_feinheit': me_feinheit,
      'me_dca': me_dca,
      'me_xrd': me_xrd,
    };
  }

  @override
  String toString() {
    return 'MaterialEigenschaften{me_id: $me_id, ofenId: $ofenId, me_charge: $me_charge, me_dichte: $me_dichte, me_feinheit: $me_feinheit, me_dca: $me_dca, me_xrd: $me_xrd}';
  }
}

// Nachmahlung Class
class Nachmahlung {
  final int? n_id;
  final int materialEigenschaftenId;
  final String n_charge;
  final bool n_erledigt;
  final String n_muehleTyp;
  final double n_mahlDauer;
  final String n_grad;
  final double n_dichte;
  final double n_feinheit;
  final double n_gluehverlust;
  final double n_dca;
  final String n_xrd;

  Nachmahlung({
    this.n_id,
    required this.materialEigenschaftenId,
    required this.n_charge,
    required this.n_erledigt,
    required this.n_muehleTyp,
    required this.n_mahlDauer,
    required this.n_grad,
    required this.n_dichte,
    required this.n_feinheit,
    required this.n_gluehverlust,
    required this.n_dca,
    required this.n_xrd,
  });

  Map<String, Object?> toMap() {
    return {
      'n_id': n_id,
      'material_eigenschaften_id': materialEigenschaftenId,
      'n_charge': n_charge,
      'n_erledigt': n_erledigt ? 1 : 0,
      'n_muehle_typ': n_muehleTyp,
      'n_mahl_dauer': n_mahlDauer,
      'n_grad': n_grad,
      'n_dichte': n_dichte,
      'n_feinheit': n_feinheit,
      'n_gluehverlust': n_gluehverlust,
      'n_dca': n_dca,
      'n_xrd': n_xrd,
    };
  }

  @override
  String toString() {
    return 'Nachmahlung{n_id: $n_id, materialEigenschaftenId: $materialEigenschaftenId, n_charge: $n_charge, n_erledigt: $n_erledigt, n_muehleTyp: $n_muehleTyp, n_mahlDauer: $n_mahlDauer, n_grad: $n_grad, n_dichte: $n_dichte, n_feinheit: $n_feinheit, n_gluehverlust: $n_gluehverlust, n_dca: $n_dca, n_xrd: $n_xrd}';
  }
}

// MoertelZusammensetzung Class
class MoertelZusammensetzung {
  final int? mz_id;
  final int nachmahlungId;
  final String mz_serie;
  final String mz_bindemittel;
  final double mz_bindemittelgehalt;
  final double mz_wasser;
  final double mz_wBmWert;
  final double mz_fliessmittel;
  final double mz_druckfestigkeit7d;

  MoertelZusammensetzung({
    this.mz_id,
    required this.nachmahlungId,
    required this.mz_serie,
    required this.mz_bindemittel,
    required this.mz_bindemittelgehalt,
    required this.mz_wasser,
    required this.mz_wBmWert,
    required this.mz_fliessmittel,
    required this.mz_druckfestigkeit7d,
  });

  Map<String, Object?> toMap() {
    return {
      'mz_id': mz_id,
      'nachmahlung_id': nachmahlungId,
      'mz_serie': mz_serie,
      'mz_bindemittel': mz_bindemittel,
      'mz_bindemittelgehalt': mz_bindemittelgehalt,
      'mz_wasser': mz_wasser,
      'mz_w_bm_wert': mz_wBmWert,
      'mz_fliessmittel': mz_fliessmittel,
      'mz_druckfestigkeit_7d': mz_druckfestigkeit7d,
    };
  }

  @override
  String toString() {
    return 'MoertelZusammensetzung{mz_id: $mz_id, nachmahlungId: $nachmahlungId, mz_serie: $mz_serie, mz_bindemittel: $mz_bindemittel, mz_bindemittelgehalt: $mz_bindemittelgehalt, mz_wasser: $mz_wasser, mz_wBmWert: $mz_wBmWert, mz_fliessmittel: $mz_fliessmittel, mz_druckfestigkeit7d: $mz_druckfestigkeit7d}';
  }
}

// BetonZusammensetzung Class
class BetonZusammensetzung {
  final int? b_id;
  final int moertelZusammensetzungId;
  final String b_serie;
  final String b_bindemittel;
  final double b_bindemittelgehalt;
  final double b_wasser;
  final double b_wBmWert;
  final double b_fliessmittel;
  final String b_sieblinie;
  final double b_druckfestigkeit;

  BetonZusammensetzung({
    this.b_id,
    required this.moertelZusammensetzungId,
    required this.b_serie,
    required this.b_bindemittel,
    required this.b_bindemittelgehalt,
    required this.b_wasser,
    required this.b_wBmWert,
    required this.b_fliessmittel,
    required this.b_sieblinie,
    required this.b_druckfestigkeit,
  });

  Map<String, Object?> toMap() {
    return {
      'b_id': b_id,
      'moertel_zusammensetzung_id': moertelZusammensetzungId,
      'b_serie': b_serie,
      'b_bindemittel': b_bindemittel,
      'b_bindemittelgehalt': b_bindemittelgehalt,
      'b_wasser': b_wasser,
      'b_w_bm_wert': b_wBmWert,
      'b_fliessmittel': b_fliessmittel,
      'b_sieblinie': b_sieblinie,
      'b_druckfestigkeit': b_druckfestigkeit,
    };
  }

  @override
  String toString() {
    return 'BetonZusammensetzung{b_id: $b_id, moertelZusammensetzungId: $moertelZusammensetzungId, b_serie: $b_serie, b_bindemittel: $b_bindemittel, b_bindemittelgehalt: $b_bindemittelgehalt, b_wasser: $b_wasser, b_wBmWert: $b_wBmWert, b_fliessmittel: $b_fliessmittel, b_sieblinie: $b_sieblinie, b_druckfestigkeit: $b_druckfestigkeit}';
  }
}

// Helper class to define search field properties
class SearchField {
  final String name;
  final String label;
  final TextInputType inputType;

  SearchField(this.name, this.label, this.inputType);
}