CREATE OR REPLACE PACKAGE custom_err IS

	crevision CONSTANT VARCHAR(100) := '$Rev: 45215 $';

	TYPE typecontextrec IS RECORD(
		 code  NUMBER
		,place VARCHAR(32767)
		,text  VARCHAR(32767));

	FUNCTION geterror RETURN VARCHAR;
	FUNCTION geterror(perrorcode IN NUMBER) RETURN VARCHAR;
	FUNCTION geterrorcode RETURN NUMBER;
	FUNCTION getfullmessage RETURN VARCHAR;
	FUNCTION getmessage(perrorcode IN NUMBER) RETURN VARCHAR;
	FUNCTION getplace RETURN VARCHAR;
	FUNCTION gettext RETURN VARCHAR;
	FUNCTION gettext(perrorcode IN NUMBER) RETURN VARCHAR;
	PROCEDURE saveerror;
	PROCEDURE seterror
	(
		perrorcode  IN NUMBER
	   ,perrorplace IN VARCHAR
	   ,perrortext  VARCHAR := NULL
	);
	PROCEDURE restoreerror;

	FUNCTION getcontext RETURN typecontextrec;
	PROCEDURE putcontext
	(
		pcontext typecontextrec
	   ,pplace   VARCHAR := NULL
	);

	FUNCTION getversion RETURN VARCHAR;

	account_invalid_handle        CONSTANT NUMBER := 200;
	account_not_found             CONSTANT NUMBER := 201;
	account_busy                  CONSTANT NUMBER := 202;
	account_debit_error           CONSTANT NUMBER := 203;
	account_credit_error          CONSTANT NUMBER := 204;
	account_ophist_busy           CONSTANT NUMBER := 205;
	account_duplicate_accountno   CONSTANT NUMBER := 206;
	account_veto                  CONSTANT NUMBER := 207;
	account_invalid               CONSTANT NUMBER := 208;
	account_objects_exist         CONSTANT NUMBER := 209;
	account_security_failure      CONSTANT NUMBER := 210;
	account_duplicate_external    CONSTANT NUMBER := 211;
	account_invalid_value         CONSTANT NUMBER := 212;
	account_invalid_length        CONSTANT NUMBER := 213;
	account_revision_changed      CONSTANT NUMBER := 214;
	account_negative_on_liability CONSTANT NUMBER := 215;
	account_positive_on_active    CONSTANT NUMBER := 216;
	account_belongs_to_contract   CONSTANT NUMBER := 217;
	account_closed                CONSTANT NUMBER := 218;
	account_remain_nonzero        CONSTANT NUMBER := 219;
	account_external_undefined    CONSTANT NUMBER := 220;
	account_pamount_forbidden     CONSTANT NUMBER := 221;
	account_holds_exist           CONSTANT NUMBER := 222;

	contract_exist_active_items    CONSTANT NUMBER := 300;
	contract_exists_primary        CONSTANT NUMBER := 301;
	contract_security_failure      CONSTANT NUMBER := 302;
	contract_not_found             CONSTANT NUMBER := 303;
	contract_item_not_found        CONSTANT NUMBER := 304;
	contract_busy                  CONSTANT NUMBER := 305;
	contract_closed                CONSTANT NUMBER := 306;
	contract_invalid_status        CONSTANT NUMBER := 307;
	contract_duplicate_no          CONSTANT NUMBER := 308;
	contract_illegal_operation     CONSTANT NUMBER := 309;
	contract_type_not_init         CONSTANT NUMBER := 310;
	contract_violation             CONSTANT NUMBER := 311;
	contract_deposit_too_small     CONSTANT NUMBER := 312;
	contract_process_warning       CONSTANT NUMBER := 313;
	contract_resident_disagree     CONSTANT NUMBER := 314;
	contract_link_not_found        CONSTANT NUMBER := 315;
	contract_revision_changed      CONSTANT NUMBER := 316;
	contract_card_product_inactive CONSTANT NUMBER := 317;

	client_invalid_handle          CONSTANT NUMBER := 400;
	client_not_found               CONSTANT NUMBER := 401;
	client_busy                    CONSTANT NUMBER := 402;
	client_unknown_type            CONSTANT NUMBER := 403;
	client_objects_exist           CONSTANT NUMBER := 404;
	client_blocked                 CONSTANT NUMBER := 405;
	client_duplicate_external_id   CONSTANT NUMBER := 406;
	client_duplicate_add_contact   CONSTANT NUMBER := 407;
	client_duplicate_add_document  CONSTANT NUMBER := 408;
	client_duplicate_ask           CONSTANT NUMBER := 409;
	client_revision_changed        CONSTANT NUMBER := 410;
	client_ask_not_found           CONSTANT NUMBER := 411;
	client_duplicate_id            CONSTANT NUMBER := 412;
	client_alias_not_found         CONSTANT NUMBER := 413;
	client_alias_service_not_found CONSTANT NUMBER := 414;
	client_duplicate_alias_service CONSTANT NUMBER := 415;
	client_alias_owner_another     CONSTANT NUMBER := 416;
	client_category_not_found      CONSTANT NUMBER := 417;

	identity_invalid_handle CONSTANT NUMBER := 500;
	identity_not_found      CONSTANT NUMBER := 501;
	identity_busy           CONSTANT NUMBER := 502;
	identity_unknown_type   CONSTANT NUMBER := 503;
	identity_duplicate_no   CONSTANT NUMBER := 504;
	identity_invalid_no     CONSTANT NUMBER := 505;

	datamember_not_found      CONSTANT NUMBER := 600;
	datamember_item_not_found CONSTANT NUMBER := 601;
	datamember_is_not_history CONSTANT NUMBER := 602;
	datamember_is_history     CONSTANT NUMBER := 603;

	customer_invalid_handle        CONSTANT NUMBER := 700;
	customer_not_found             CONSTANT NUMBER := 701;
	customer_busy                  CONSTANT NUMBER := 702;
	customer_security_failure      CONSTANT NUMBER := 703;
	customer_duplicate             CONSTANT NUMBER := 704;
	customer_objects_exist         CONSTANT NUMBER := 705;
	customer_dublicate_charalias   CONSTANT NUMBER := 706;
	customer_stat_not_found        CONSTANT NUMBER := 707;
	customer_invalid_length        CONSTANT NUMBER := 708;
	customer_duplicate_authcard    CONSTANT NUMBER := 709;
	customer_duplicate_account     CONSTANT NUMBER := 710;
	customer_duplicate_card        CONSTANT NUMBER := 711;
	customer_duplicate_phone       CONSTANT NUMBER := 712;
	customer_duplicate_email       CONSTANT NUMBER := 713;
	customer_revision_changed      CONSTANT NUMBER := 714;
	customer_acc_link_not_found    CONSTANT NUMBER := 715;
	customer_acc_link_exists       CONSTANT NUMBER := 716;
	customer_duplicate_external_id CONSTANT NUMBER := 717;

	clerk_not_found CONSTANT NUMBER := 800;
	clerk_busy      CONSTANT NUMBER := 801;

	accounttype_invalid_handle    CONSTANT NUMBER := 900;
	accounttype_not_found         CONSTANT NUMBER := 901;
	accounttype_busy              CONSTANT NUMBER := 902;
	accounttype_busy_all          CONSTANT NUMBER := 903;
	accounttype_unknown_genmethod CONSTANT NUMBER := 904;
	accounttype_undefined_bcode   CONSTANT NUMBER := 905;
	accounttype_undefined_bic     CONSTANT NUMBER := 906;
	accounttype_seq_overflow      CONSTANT NUMBER := 907;

	refct_item_not_found           CONSTANT NUMBER := 1000;
	refct_undefined_cardproduct    CONSTANT NUMBER := 1001;
	refct_undefined_cardcreatemode CONSTANT NUMBER := 1002;
	refct_undefined_acccreatemode  CONSTANT NUMBER := 1003;
	refct_undefined_createtype     CONSTANT NUMBER := 1004;
	refct_undefined_acctype        CONSTANT NUMBER := 1005;
	refct_undefined_acct_typ       CONSTANT NUMBER := 1006;
	refct_undefined_acct_stat      CONSTANT NUMBER := 1007;
	refct_cn_invalid_length        CONSTANT NUMBER := 1008;
	refct_cn_create_seq_failure    CONSTANT NUMBER := 1009;
	refct_cn_seq_overflow          CONSTANT NUMBER := 1010;
	refct_cn_number_overflow       CONSTANT NUMBER := 1011;
	refct_cn_notdefined            CONSTANT NUMBER := 1012;
	refct_schema_invalid_setup     CONSTANT NUMBER := 1013;
	refct_undefined_schema         CONSTANT NUMBER := 1014;
	refct_undefined_oper           CONSTANT NUMBER := 1015;
	refct_undefined_ledger         CONSTANT NUMBER := 1016;
	refct_undefined_subledger      CONSTANT NUMBER := 1017;
	refct_undefined_sign           CONSTANT NUMBER := 1018;
	refct_undefined_plastictype    CONSTANT NUMBER := 1019;

	card_invalid_handle           CONSTANT NUMBER := 1100;
	card_not_found                CONSTANT NUMBER := 1101;
	card_busy                     CONSTANT NUMBER := 1102;
	card_security_failure         CONSTANT NUMBER := 1103;
	card_delete_primary           CONSTANT NUMBER := 1104;
	card_duplicate                CONSTANT NUMBER := 1109;
	card_objects_exist            CONSTANT NUMBER := 1111;
	card_account_limit            CONSTANT NUMBER := 1112;
	card_account_link_not_found   CONSTANT NUMBER := 1113;
	card_account_link_exists      CONSTANT NUMBER := 1114;
	card_remake_disable           CONSTANT NUMBER := 1115;
	card_trans_sign_err           CONSTANT NUMBER := 1116;
	card_trans_stat_err           CONSTANT NUMBER := 1117;
	card_invalid_expdate          CONSTANT NUMBER := 1118;
	card_account_link_many_found  CONSTANT NUMBER := 1119;
	card_create_account_is_closed CONSTANT NUMBER := 1120;
	card_revision_changed         CONSTANT NUMBER := 1121;
	card_invalid_owner_type       CONSTANT NUMBER := 1122;
	card_account_link_error       CONSTANT NUMBER := 1123;
	card_duplicate_external_id    CONSTANT NUMBER := 1124;
	card_not_allowed_additional   CONSTANT NUMBER := 1125;

	object_internal_error       CONSTANT NUMBER := 1200;
	object_not_found            CONSTANT NUMBER := 1201;
	object_busy                 CONSTANT NUMBER := 1202;
	object_revision_changed     CONSTANT NUMBER := 1204;
	object_type_dublicate       CONSTANT NUMBER := 1205;
	object_userprop_not_found   CONSTANT NUMBER := 1210;
	object_userprop_undefined   CONSTANT NUMBER := 1211;
	object_userprop_invalid_len CONSTANT NUMBER := 1212;
	object_userprop_locked      CONSTANT NUMBER := 1213;
	object_userprop_unique      CONSTANT NUMBER := 1214;

	event_setup_not_found CONSTANT NUMBER := 1300;
	event_not_found       CONSTANT NUMBER := 1301;
	event_delete_denied   CONSTANT NUMBER := 1302;
	event_execute_denied  CONSTANT NUMBER := 1303;

	schema_crdstamp_not_found    CONSTANT NUMBER := 1400;
	schema_prcstamp_not_found    CONSTANT NUMBER := 1401;
	schema_invalid_undo_ident    CONSTANT NUMBER := 1402;
	schema_credit_limit_exceeded CONSTANT NUMBER := 1403;

	planaccount_plan_not_found   CONSTANT NUMBER := 1500;
	planaccount_invalid_division CONSTANT NUMBER := 1501;
	planaccount_invalid_link     CONSTANT NUMBER := 1502;
	planaccount_invalid_type     CONSTANT NUMBER := 1503;
	planaccount_empty            CONSTANT NUMBER := 1504;
	planaccount_duplicate_link   CONSTANT NUMBER := 1505;
	planaccount_security_failure CONSTANT NUMBER := 1506;
	planaccount_duplicate        CONSTANT NUMBER := 1507;
	planaccount_acctype_exists   CONSTANT NUMBER := 1508;
	planaccount_invalid_sign     CONSTANT NUMBER := 1509;
	planaccount_invalid_field    CONSTANT NUMBER := 1510;
	planaccount_invalid_script   CONSTANT NUMBER := 1511;

	plan_account_busy CONSTANT NUMBER := 1600;

	entry_not_found               CONSTANT NUMBER := 1700;
	entry_invalid_entcode         CONSTANT NUMBER := 1701;
	entry_invalid_debitaccountno  CONSTANT NUMBER := 1702;
	entry_invalid_creditaccountno CONSTANT NUMBER := 1703;
	entry_account_is_closed       CONSTANT NUMBER := 1704;
	entry_illegal_delete          CONSTANT NUMBER := 1705;
	entry_illegal_update          CONSTANT NUMBER := 1706;
	entry_debit_credit_identical  CONSTANT NUMBER := 1707;
	entry_currency_difference     CONSTANT NUMBER := 1708;
	entry_cashlimit_exceeded      CONSTANT NUMBER := 1709;
	entry_nocashlimit_exceeded    CONSTANT NUMBER := 1710;
	entry_monthlimit_exceeded     CONSTANT NUMBER := 1711;
	entry_child_exists            CONSTANT NUMBER := 1712;
	entry_wrong_parent            CONSTANT NUMBER := 1713;
	entry_debcashlimit_exceeded   CONSTANT NUMBER := 1714;
	entry_debnocashlimit_exceeded CONSTANT NUMBER := 1715;
	entry_debmonthlimit_exceeded  CONSTANT NUMBER := 1716;
	entry_invalid_value           CONSTANT NUMBER := 1717;
	entry_illegal_reverse         CONSTANT NUMBER := 1718;
	entry_illegal_cancel_delete   CONSTANT NUMBER := 1719;
	entry_docno_not_found         CONSTANT NUMBER := 1720;
	entry_incomplete_detail       CONSTANT NUMBER := 1721;

	seance_login_timeout      CONSTANT NUMBER := 1800;
	seance_users_exist        CONSTANT NUMBER := 1801;
	seance_opday_already_open CONSTANT NUMBER := 1802;
	seance_opday_not_open     CONSTANT NUMBER := 1803;
	seance_opday_not_end      CONSTANT NUMBER := 1804;
	seance_bad_regim          CONSTANT NUMBER := 1805;
	seance_invalid_branch     CONSTANT NUMBER := 1806;
	seance_invalid_currency   CONSTANT NUMBER := 1807;
	seance_access_limited     CONSTANT NUMBER := 1808;

	limit_not_found            CONSTANT NUMBER := 1900;
	limit_card_not_found       CONSTANT NUMBER := 1901;
	limit_currency_difference  CONSTANT NUMBER := 1902;
	limit_account_not_found    CONSTANT NUMBER := 1903;
	limit_acc2card_not_found   CONSTANT NUMBER := 1904;
	limit_customer_not_found   CONSTANT NUMBER := 1905;
	limit_invalid_group_id     CONSTANT NUMBER := 1906;
	limit_chequebook_not_found CONSTANT NUMBER := 1907;
	limit_chequebook_exceeded  CONSTANT NUMBER := 1908;

	limit_retailer_not_found CONSTANT NUMBER := 1909;
	limit_terminal_not_found CONSTANT NUMBER := 1910;
	limit_card_exceeded      CONSTANT NUMBER := 1911;
	limit_account_exceeded   CONSTANT NUMBER := 1912;
	limit_retailer_exceeded  CONSTANT NUMBER := 1913;
	limit_terminal_exceeded  CONSTANT NUMBER := 1914;
	limit_client_not_found   CONSTANT NUMBER := 1915;
	limit_client_exceeded    CONSTANT NUMBER := 1916;

	counter_not_found             CONSTANT NUMBER := 1950;
	counter_account_lim_not_found CONSTANT NUMBER := 1951;
	counter_card_lim_not_found    CONSTANT NUMBER := 1952;
	counter_client_lim_not_found  CONSTANT NUMBER := 1953;

	cms_create_failed      CONSTANT NUMBER := 2000;
	cms_card_create_failed CONSTANT NUMBER := 2001;

	cms_client_not_define      CONSTANT NUMBER := 2003;
	cms_scheme_not_define      CONSTANT NUMBER := 2004;
	cms_channel_not_define     CONSTANT NUMBER := 2005;
	cms_address_not_define     CONSTANT NUMBER := 2006;
	cms_not_found              CONSTANT NUMBER := 2007;
	cms_card_not_found         CONSTANT NUMBER := 2008;
	cms_customer_not_found     CONSTANT NUMBER := 2009;
	cms_busy                   CONSTANT NUMBER := 2010;
	cms_invalid_handle         CONSTANT NUMBER := 2011;
	cms_revision_changed       CONSTANT NUMBER := 2012;
	cms_customer_create_failed CONSTANT NUMBER := 2013;
	cms_duplicate_external_id  CONSTANT NUMBER := 2014;
	cms_retailer_not_found     CONSTANT NUMBER := 2015;
	cms_retailer_create_failed CONSTANT NUMBER := 2016;

	app_invalid_handle   CONSTANT NUMBER := 2200;
	app_not_found        CONSTANT NUMBER := 2201;
	app_busy             CONSTANT NUMBER := 2202;
	app_no_large         CONSTANT NUMBER := 2203;
	app_no_small         CONSTANT NUMBER := 2204;
	app_no_gen_unknown   CONSTANT NUMBER := 2205;
	app_no_seq_exceeded  CONSTANT NUMBER := 2206;
	app_revision_changed CONSTANT NUMBER := 2221;
	app_unknown_state    CONSTANT NUMBER := 2222;
	app_unknown_decline  CONSTANT NUMBER := 2223;
	app_wrong_state      CONSTANT NUMBER := 2224;
	app_wrong_decline    CONSTANT NUMBER := 2225;

	img_imagetype_not_found     CONSTANT NUMBER := 2301;
	img_imagetype_create_failed CONSTANT NUMBER := 2302;
	img_imagetype_modify_failed CONSTANT NUMBER := 2303;
	img_imagetype_delete_failed CONSTANT NUMBER := 2304;
	img_doctype_not_found       CONSTANT NUMBER := 2311;
	img_doctype_create_failed   CONSTANT NUMBER := 2312;
	img_doctype_modify_failed   CONSTANT NUMBER := 2313;
	img_doctype_delete_failed   CONSTANT NUMBER := 2314;

	refcalendar_not_found CONSTANT NUMBER := 2400;

	chequebook_not_found        CONSTANT NUMBER := 2501;
	chequebook_invalid_handle   CONSTANT NUMBER := 2502;
	chequebook_revision_changed CONSTANT NUMBER := 2503;
	chequebook_busy             CONSTANT NUMBER := 2504;

	cheque_not_found        CONSTANT NUMBER := 2551;
	cheque_invalid_handle   CONSTANT NUMBER := 2552;
	cheque_revision_changed CONSTANT NUMBER := 2553;
	cheque_busy             CONSTANT NUMBER := 2554;
	cheque_invalid_status   CONSTANT NUMBER := 2555;

	chequerequest_not_found        CONSTANT NUMBER := 2601;
	chequerequest_invalid_handle   CONSTANT NUMBER := 2602;
	chequerequest_revision_changed CONSTANT NUMBER := 2603;
	chequerequest_busy             CONSTANT NUMBER := 2604;

	collect_other               CONSTANT NUMBER := 2700;
	collect_case_create_failed  CONSTANT NUMBER := 2701;
	collect_case_not_found      CONSTANT NUMBER := 2702;
	collect_case_add_obj_failed CONSTANT NUMBER := 2703;
	collect_case_is_closed      CONSTANT NUMBER := 2704;
	collect_case_seq_overflow   CONSTANT NUMBER := 2705;

	collect_class_create_failed CONSTANT NUMBER := 2720;
	collect_class_not_found     CONSTANT NUMBER := 2721;

	collect_action_not_found CONSTANT NUMBER := 2730;
	collect_action_not_exec  CONSTANT NUMBER := 2731;

	ue_data_not_found       CONSTANT NUMBER := 4000;
	ue_value_incorrect      CONSTANT NUMBER := 4001;
	ue_value_notdefined     CONSTANT NUMBER := 4002;
	ue_value_negative       CONSTANT NUMBER := 4003;
	ue_value_notpositive    CONSTANT NUMBER := 4004;
	ue_value_float          CONSTANT NUMBER := 4005;
	ue_value_large          CONSTANT NUMBER := 4006;
	ue_value_small          CONSTANT NUMBER := 4007;
	ue_value_duplicated     CONSTANT NUMBER := 4008;
	ue_data_too_many        CONSTANT NUMBER := 4009;
	ue_utype_incorrecttype  CONSTANT NUMBER := 4100;
	ue_crc_incorrect        CONSTANT NUMBER := 4101;
	ue_crc_not_found        CONSTANT NUMBER := 4102;
	ue_other                CONSTANT NUMBER := 4111;
	ue_module_not_supported CONSTANT NUMBER := 4114;
	ue_timeout              CONSTANT NUMBER := 4115;

	dc_not_found           CONSTANT NUMBER := 4200;
	dc_value_incorrect     CONSTANT NUMBER := 4201;
	dc_setupdata_incorrect CONSTANT NUMBER := 4202;
	dc_method_notdefined   CONSTANT NUMBER := 4203;

	extract_invalid_telebank       CONSTANT NUMBER := 5002;
	extract_invalid_card           CONSTANT NUMBER := 5003;
	extract_invalid_adjustment     CONSTANT NUMBER := 5004;
	extract_auth_not_found         CONSTANT NUMBER := 5005;
	extract_auth_too_many          CONSTANT NUMBER := 5006;
	extract_undefined_packagename  CONSTANT NUMBER := 5007;
	extract_invalid_packagename    CONSTANT NUMBER := 5008;
	extract_invalid_orgvalue       CONSTANT NUMBER := 5009;
	extract_reversal_failure       CONSTANT NUMBER := 5012;
	extract_invalid_acquirer       CONSTANT NUMBER := 5013;
	extract_invalid_userdata       CONSTANT NUMBER := 5014;
	extract_invalid_setup_currency CONSTANT NUMBER := 5015;
	extract_invalid_messageno      CONSTANT NUMBER := 5016;
	extract_invalid_enttype        CONSTANT NUMBER := 5020;

	extract_invalid_disp_currency CONSTANT NUMBER := 5021;

	extract_invalid_fiid           CONSTANT NUMBER := 5031;
	extract_invalid_currency       CONSTANT NUMBER := 5032;
	extract_invalid_orgcurrency    CONSTANT NUMBER := 5033;
	extract_invalid_ta_currency    CONSTANT NUMBER := 5034;
	extract_invalid_other_currency CONSTANT NUMBER := 5035;
	extract_invalid_exchange       CONSTANT NUMBER := 5036;
	extract_invalid_value          CONSTANT NUMBER := 5037;
	extract_invalid_sign           CONSTANT NUMBER := 5038;
	extract_invalid_emv            CONSTANT NUMBER := 5039;

	extract_undefined_fee_account CONSTANT NUMBER := 5040;
	extract_dummy_proceed         CONSTANT NUMBER := 5041;
	extract_unsettled_rule        CONSTANT NUMBER := 5042;
	extract_unsettled_proc        CONSTANT NUMBER := 5043;
	extract_hold_invalid_proc     CONSTANT NUMBER := 5044;
	extract_hold_no_proc          CONSTANT NUMBER := 5045;
	extract_hold_invalid          CONSTANT NUMBER := 5046;
	extract_auth_one_from_many    CONSTANT NUMBER := 5047;
	extract_acct_invalid_proc     CONSTANT NUMBER := 5048;
	extract_acct_too_many         CONSTANT NUMBER := 5049;
	extract_invalid_crdstat       CONSTANT NUMBER := 5050;
	extract_link_exists           CONSTANT NUMBER := 5051;
	extract_invalid_acctcurrency  CONSTANT NUMBER := 5052;
	extract_invalid_cardtype      CONSTANT NUMBER := 5053;
	extract_invalid_payment_param CONSTANT NUMBER := 5054;
	extract_docno_is_null         CONSTANT NUMBER := 5055;

	extract_unsupported_method   CONSTANT NUMBER := 5056;
	extract_different_oldcrdstat CONSTANT NUMBER := 5057;
	extract_duplicate_newcrdstat CONSTANT NUMBER := 5058;

	extract_unsettled_rule_toomany CONSTANT NUMBER := 5059;
	extract_invalid_rev_currency   CONSTANT NUMBER := 5060;

	extract_invalid_mcc         CONSTANT NUMBER := 5061;
	extract_cardprofile_is_null CONSTANT NUMBER := 5062;
	extract_invalid_cardprofile CONSTANT NUMBER := 5063;
	extract_error_transaction   CONSTANT NUMBER := 5064;
	extract_unauth_transaction  CONSTANT NUMBER := 5065;

	import_clipboard_open_error  CONSTANT NUMBER := 5102;
	import_clipboard_read_error  CONSTANT NUMBER := 5103;
	import_clipboard_write_error CONSTANT NUMBER := 5104;

	capitalise_account_empty       CONSTANT NUMBER := 5200;
	capitalise_made                CONSTANT NUMBER := 5201;
	capitalise_percent_not_found   CONSTANT NUMBER := 5202;
	capitalise_undefined_procedure CONSTANT NUMBER := 5203;
	capitalise_link_not_found      CONSTANT NUMBER := 5204;
	capitalise_invalid_parameters  CONSTANT NUMBER := 5205;

	inop_internal_error           CONSTANT NUMBER := 5301;
	inop_invalid_account          CONSTANT NUMBER := 5302;
	inop_invalid_client           CONSTANT NUMBER := 5303;
	inop_invalid_passport         CONSTANT NUMBER := 5304;
	inop_invalid_fio              CONSTANT NUMBER := 5305;
	inop_fio_notexist             CONSTANT NUMBER := 5306;
	inop_fio_different            CONSTANT NUMBER := 5307;
	inop_account_exist            CONSTANT NUMBER := 5308;
	inop_pack_locked              CONSTANT NUMBER := 5309;
	inop_invalid_credit_line      CONSTANT NUMBER := 5310;
	inop_credit_account_not_found CONSTANT NUMBER := 5311;
	inop_invalid_handle           CONSTANT NUMBER := 5312;
	inop_account_not_found        CONSTANT NUMBER := 5313;
	inop_remain_greatest          CONSTANT NUMBER := 5314;
	inop_invalid_value            CONSTANT NUMBER := 5315;
	inop_error_open_accountcrd    CONSTANT NUMBER := 5316;
	inop_account_isnot_credit     CONSTANT NUMBER := 5317;
	inop_extdata_not_found        CONSTANT NUMBER := 5318;
	inop_error_type               CONSTANT NUMBER := 5319;
	inop_debitstat_not_permit     CONSTANT NUMBER := 5320;
	inop_creditstat_not_permit    CONSTANT NUMBER := 5321;
	inop_invalid_card             CONSTANT NUMBER := 5322;
	inop_schema_hasnot_oper       CONSTANT NUMBER := 5323;
	inop_invalid_tabno            CONSTANT NUMBER := 5324;
	inop_invalid_office           CONSTANT NUMBER := 5325;
	inop_invalid_company          CONSTANT NUMBER := 5326;
	inop_too_many_contract        CONSTANT NUMBER := 5327;

	issue_client_not_found       CONSTANT NUMBER := 5400;
	issue_account_already_exist  CONSTANT NUMBER := 5401;
	issue_identity_already_exist CONSTANT NUMBER := 5402;
	issue_card_not_found         CONSTANT NUMBER := 5403;
	issue_card_activ             CONSTANT NUMBER := 5404;
	issue_duplicate_external     CONSTANT NUMBER := 5405;

	bop_oper_not_found           CONSTANT NUMBER := 5500;
	bop_oper_pack_exists         CONSTANT NUMBER := 5501;
	bop_oper_undefined           CONSTANT NUMBER := 5502;
	bop_oper_ident_notdefined    CONSTANT NUMBER := 5503;
	bop_oper_ident_duplicate     CONSTANT NUMBER := 5504;
	bop_oper_ident_invalid       CONSTANT NUMBER := 5505;
	bop_oper_name_notdefined     CONSTANT NUMBER := 5506;
	bop_oper_mode_mismatch       CONSTANT NUMBER := 5507;
	bop_oper_fld_revision_change CONSTANT NUMBER := 5508;
	bop_oper_fld_locked          CONSTANT NUMBER := 5509;
	bop_module_not_found         CONSTANT NUMBER := 5510;
	bop_templ_not_found          CONSTANT NUMBER := 5511;
	bop_packet_not_found         CONSTANT NUMBER := 5512;
	bop_packet_undefined         CONSTANT NUMBER := 5513;
	bop_record_not_found         CONSTANT NUMBER := 5514;
	bop_module_mode_mismatch     CONSTANT NUMBER := 5515;
	bop_module_ident_notdefined  CONSTANT NUMBER := 5516;
	bop_module_name_notdefined   CONSTANT NUMBER := 5517;
	bop_module_ident_duplicate   CONSTANT NUMBER := 5518;
	bop_templ_ident_notdefined   CONSTANT NUMBER := 5519;
	bop_templ_name_notdefined    CONSTANT NUMBER := 5520;
	bop_templ_ident_duplicate    CONSTANT NUMBER := 5521;
	bop_module_ident_invalid     CONSTANT NUMBER := 5522;
	bop_packet_duplicate         CONSTANT NUMBER := 5523;

	bop_oper_inactive           CONSTANT NUMBER := 5524;
	bop_oper_templ_mismatch     CONSTANT NUMBER := 5525;
	bop_templ_type_mismatch     CONSTANT NUMBER := 5526;
	bop_templ_inactive          CONSTANT NUMBER := 5527;
	bop_module_inactive         CONSTANT NUMBER := 5528;
	bop_module_block_notdefined CONSTANT NUMBER := 5529;
	bop_script_error            CONSTANT NUMBER := 5530;
	bop_packet_locked           CONSTANT NUMBER := 5531;
	bop_fld_not_found           CONSTANT NUMBER := 5532;
	bop_group_ident_invalid     CONSTANT NUMBER := 5533;
	bop_record_invalid          CONSTANT NUMBER := 5534;

	payment_template_notfound     CONSTANT NUMBER := 5600;
	payment_dest_not_found        CONSTANT NUMBER := 5601;
	payment_attr_not_found        CONSTANT NUMBER := 5602;
	payment_attr_empty            CONSTANT NUMBER := 5603;
	payment_attr_scr_raise        CONSTANT NUMBER := 5604;
	payment_refinfo_not_found     CONSTANT NUMBER := 5605;
	payment_parse_mask_error      CONSTANT NUMBER := 5606;
	payment_atmpay_not_found      CONSTANT NUMBER := 5607;
	payment_destfield_not_found   CONSTANT NUMBER := 5608;
	payment_unsupport_transaction CONSTANT NUMBER := 5609;
	payment_unknow_atm_mode       CONSTANT NUMBER := 5610;
	payment_info_scr_raise        CONSTANT NUMBER := 5611;
	payment_expiration            CONSTANT NUMBER := 5612;
	payment_invalid_checkvalue    CONSTANT NUMBER := 5613;
	payment_host_not_found        CONSTANT NUMBER := 5614;
	payment_standorder_not_found  CONSTANT NUMBER := 5615;

	adjustment_invalid_transaction CONSTANT NUMBER := 5700;

	refresh_invalid_setup_currency CONSTANT NUMBER := 5800;
	refresh_invalid_setup_contract CONSTANT NUMBER := 5801;

	a4mfo_reverse_excluding    CONSTANT NUMBER := 5900;
	a4mfo_unknow_value         CONSTANT NUMBER := 5901;
	a4mfo_not_approved         CONSTANT NUMBER := 5902;
	a4mfo_length_too_match     CONSTANT NUMBER := 5903;
	a4mfo_original_not_found   CONSTANT NUMBER := 5904;
	a4mfo_dup_reverse          CONSTANT NUMBER := 5905;
	a4mfo_tran_error           CONSTANT NUMBER := 5906;
	a4mfo_unknow_type_tran     CONSTANT NUMBER := 5907;
	a4mfo_unknow_term_class    CONSTANT NUMBER := 5908;
	a4mfo_unknow_reason        CONSTANT NUMBER := 5909;
	a4mfo_original_more_one    CONSTANT NUMBER := 5910;
	a4mfo_invalid_origtrantype CONSTANT NUMBER := 5911;
	a4mfo_invalid_adjustment   CONSTANT NUMBER := 5912;

	mb_account_type_not_found   CONSTANT NUMBER := 5950;
	mb_corraccount_not_found    CONSTANT NUMBER := 5951;
	mb_alien_account            CONSTANT NUMBER := 5952;
	mb_error_change_acc_curr    CONSTANT NUMBER := 5953;
	mb_alien_card_product       CONSTANT NUMBER := 5954;
	mb_alien_cust_product       CONSTANT NUMBER := 5955;
	mb_linked_account_not_found CONSTANT NUMBER := 5956;
	mb_linked_card_not_found    CONSTANT NUMBER := 5957;
	mb_ident_duplicate          CONSTANT NUMBER := 5958;
	mb_parent_not_found         CONSTANT NUMBER := 5959;
	mb_not_defined_account      CONSTANT NUMBER := 5960;

	commission_proc_error CONSTANT NUMBER := 6000;

	finprofile_proc_error    CONSTANT NUMBER := 6100;
	finprofile_toomany_items CONSTANT NUMBER := 6101;
	finprofile_not_found     CONSTANT NUMBER := 6102;

	spag_parent_not_found   CONSTANT NUMBER := 6200;
	spag_original_toomany   CONSTANT NUMBER := 6201;
	spag_order_exists       CONSTANT NUMBER := 6202;
	spag_invalid_reasoncode CONSTANT NUMBER := 6203;

	installment_module_not_found   CONSTANT NUMBER := 6300;
	installment_mid_not_found      CONSTANT NUMBER := 6301;
	installment_plan_not_defined   CONSTANT NUMBER := 6302;
	installment_plan_not_found     CONSTANT NUMBER := 6303;
	installment_term_not_defined   CONSTANT NUMBER := 6304;
	installment_date_invalid       CONSTANT NUMBER := 6305;
	installment_amount_invalid     CONSTANT NUMBER := 6306;
	installment_amount_mid_invalid CONSTANT NUMBER := 6307;

	bms_request_not_found     CONSTANT NUMBER := 6500;
	bms_field_mandatory       CONSTANT NUMBER := 6501;
	bms_rule_not_found        CONSTANT NUMBER := 6502;
	bms_rule_more_found       CONSTANT NUMBER := 6503;
	bms_undo_error            CONSTANT NUMBER := 6504;
	bms_feedecline_not_define CONSTANT NUMBER := 6505;

	loyality_program_not_found  CONSTANT NUMBER := 6600;
	loyality_account_not_define CONSTANT NUMBER := 6601;
	loyality_program_security   CONSTANT NUMBER := 6602;

	dialog_invalid_handle        CONSTANT NUMBER := 7000;
	dialog_invalid_item_id       CONSTANT NUMBER := 7001;
	dialog_invalid_record_number CONSTANT NUMBER := 7002;
	dialog_duplicate_id          CONSTANT NUMBER := 7003;
	dialog_duplicate_list_name   CONSTANT NUMBER := 7004;
	dialog_invalid_list_name     CONSTANT NUMBER := 7005;
	dialog_data_not_found        CONSTANT NUMBER := 7006;

	refentry_invalid_code    CONSTANT NUMBER := 7101;
	refentry_invalid_ident   CONSTANT NUMBER := 7102;
	refentry_duplicate_ident CONSTANT NUMBER := 7103;

	refcurrency_not_found          CONSTANT NUMBER := 7201;
	refcurrency_active_notdefined  CONSTANT NUMBER := 7202;
	refcurrency_passive_notdefined CONSTANT NUMBER := 7203;
	refcurrency_rate_not_found     CONSTANT NUMBER := 7204;
	refcurrency_default_not_found  CONSTANT NUMBER := 7205;
	refcurrency_d_act_notdefined   CONSTANT NUMBER := 7206;
	refcurrency_d_pass_notdefined  CONSTANT NUMBER := 7207;

	refcrd_stat_not_found   CONSTANT NUMBER := 7301;
	refcrd_sign_not_found   CONSTANT NUMBER := 7302;
	refcrd_ecstat_not_found CONSTANT NUMBER := 7303;

	refbpart_duplicate_branchpart  CONSTANT NUMBER := 7400;
	refbpart_branchpart_not_found  CONSTANT NUMBER := 7401;
	refbpart_duplicate_station     CONSTANT NUMBER := 7402;
	refbpart_station_not_found     CONSTANT NUMBER := 7403;
	refbpart_branchpart_notdefined CONSTANT NUMBER := 7404;

	reffi_undefined_fi             CONSTANT NUMBER := 7500;
	reffi_undefined_retailer       CONSTANT NUMBER := 7501;
	reffi_undefined_terminal       CONSTANT NUMBER := 7502;
	reffi_undefined_account        CONSTANT NUMBER := 7503;
	reffi_unknown_device           CONSTANT NUMBER := 7504;
	reffi_cp_undefined             CONSTANT NUMBER := 7505;
	reffi_cp_undefined_period      CONSTANT NUMBER := 7506;
	reffi_cp_undefined_cardtype    CONSTANT NUMBER := 7507;
	reffi_cp_undefined_account     CONSTANT NUMBER := 7508;
	reffi_cp_undefined_servicecode CONSTANT NUMBER := 7509;
	reffi_cp_undefined_pvki        CONSTANT NUMBER := 7510;
	reffi_cp_undefined_limit       CONSTANT NUMBER := 7511;
	reffi_cp_cn_create_seq_failure CONSTANT NUMBER := 7512;
	reffi_cp_cn_undefined_data     CONSTANT NUMBER := 7513;
	reffi_cp_cn_seq_overflow       CONSTANT NUMBER := 7514;
	reffi_cp_cn_invalid_length     CONSTANT NUMBER := 7515;
	reffi_cp_cn_mbr_overflow       CONSTANT NUMBER := 7516;
	reffi_cp_cn_ppan_not_found     CONSTANT NUMBER := 7517;
	reffi_cp_undefined_checkmethod CONSTANT NUMBER := 7518;
	reffi_cp_strgen_undefined      CONSTANT NUMBER := 7519;
	reffi_custtype_undefined       CONSTANT NUMBER := 7520;
	reffi_cp_cn_range_not_define   CONSTANT NUMBER := 7521;
	reffi_cp_cn_range_not_found    CONSTANT NUMBER := 7522;
	reffi_term_account_not_found   CONSTANT NUMBER := 7523;
	reffi_cp_too_many_values       CONSTANT NUMBER := 7524;
	reffi_retailer_object_exists   CONSTANT NUMBER := 7525;
	reffi_terminal_object_exists   CONSTANT NUMBER := 7526;
	reffi_retailer_busy            CONSTANT NUMBER := 7529;
	reffi_terminal_busy            CONSTANT NUMBER := 7530;

	refcountry_not_found      CONSTANT NUMBER := 7601;
	refcountry_item_not_found CONSTANT NUMBER := 7602;
	refregion_item_not_found  CONSTANT NUMBER := 7603;
	refcity_item_not_found    CONSTANT NUMBER := 7604;
	refstreet_item_not_found  CONSTANT NUMBER := 7605;

	refcnschannel_not_found CONSTANT NUMBER := 7701;

	refcnsschema_not_found CONSTANT NUMBER := 7801;

	refevent_not_found CONSTANT NUMBER := 8101;

	refhold_name_not_found CONSTANT NUMBER := 8301;
	refhold_duplicate_name CONSTANT NUMBER := 8302;

	refcomm_data_not_defined CONSTANT NUMBER := 8500;

	twi_business_mode_not_defined CONSTANT NUMBER := 8600;
	twi_reject_not_found          CONSTANT NUMBER := 8601;
	twi_resubmission_not_found    CONSTANT NUMBER := 8602;

	finschema_other CONSTANT NUMBER := 30000;

	em_other          CONSTANT NUMBER := 40000;
	em_core_itp       CONSTANT NUMBER := 40001;
	em_core_itpscript CONSTANT NUMBER := 40002;

	em_oper_not_support_getinfo CONSTANT NUMBER := 40101;

	em_ro_other   CONSTANT NUMBER := 40200;
	em_ro_fimi    CONSTANT NUMBER := 40201;
	em_ro_connect CONSTANT NUMBER := 40202;

	em_fa_other         CONSTANT NUMBER := 40300;
	em_fa_doc_not_found CONSTANT NUMBER := 40301;
	em_fa_too_many_doc  CONSTANT NUMBER := 40302;
	em_fa_doc_is_frod   CONSTANT NUMBER := 40303;
	em_fa_doc_not_frod  CONSTANT NUMBER := 40304;

	mt_msg_not_sent     CONSTANT NUMBER := 50000;
	mt_msg_not_received CONSTANT NUMBER := 50001;

END;
/
CREATE OR REPLACE PACKAGE BODY custom_err IS

	cbrevision CONSTANT VARCHAR(100) := '$Rev: 44809 $';

	snontracezeroerror BOOLEAN := FALSE;

	saveerrorcode  NUMBER;
	saveerrorplace VARCHAR(32767);
	saveerrortext  VARCHAR(32767);

	serror typecontextrec;

	PROCEDURE traceerr
	(
		pcode  IN NUMBER
	   ,pplace IN VARCHAR
	   ,ptext  VARCHAR := NULL
	);
	PROCEDURE trace
	(
		pplace IN VARCHAR
	   ,ptext  IN VARCHAR
	);

	FUNCTION getversion RETURN VARCHAR IS
	BEGIN
		RETURN service.formatpackageversion('Err', crevision, cbrevision);
	END;

	FUNCTION geterror RETURN VARCHAR IS
	BEGIN
		RETURN 'TWR' || '-' || serror.code || ': ' || gettext();
	EXCEPTION
		WHEN OTHERS THEN
			RETURN(TRIM(SQLERRM(serror.code)));
	END;

	FUNCTION geterror(perrorcode IN NUMBER) RETURN VARCHAR IS
	BEGIN
		FOR i IN (SELECT /*+ Result_Ca?he */
				   errtext
				  FROM   terror
				  WHERE  errcode = perrorcode)
		LOOP
			RETURN 'TWR' || '-' || perrorcode || ': ' || TRIM(i.errtext);
		END LOOP;
		RETURN debug.viewmaskdata(TRIM(SQLERRM(perrorcode)));
	END;

	FUNCTION geterrorcode RETURN NUMBER IS
	BEGIN
		RETURN serror.code;
	END;

	FUNCTION getfullmessage RETURN VARCHAR IS
	BEGIN
	
		RETURN getplace || '~' || to_char(serror.code) || ': ' || gettext || '~';
	END;

	FUNCTION getmessage(perrorcode IN NUMBER) RETURN VARCHAR IS
	BEGIN
		RETURN REPLACE(gettext(perrorcode), '~', ' ');
	END;

	FUNCTION getplace RETURN VARCHAR IS
	BEGIN
		RETURN ltrim(rtrim(serror.place));
	END;

	FUNCTION gettext RETURN VARCHAR IS
		vtext VARCHAR(32767);
	BEGIN
		IF serror.code != error.errorconst
		THEN
			FOR i IN (SELECT /*+ Result_Ca?he */
					   errtext
					  FROM   terror
					  WHERE  errcode = serror.code)
			LOOP
				vtext := i.errtext;
			END LOOP;
		
		END IF;
	
		IF vtext IS NULL
		THEN
			vtext := serror.text;
		ELSE
			IF serror.text IS NOT NULL
			THEN
				vtext := vtext || ' [' || serror.text || ']';
			END IF;
		END IF;
	
		RETURN TRIM(vtext);
	
	EXCEPTION
		WHEN OTHERS THEN
			s.err('Err.GetText');
			RETURN 'Err.GetText : ' || debug.viewmaskdata(SQLERRM);
	END;

	FUNCTION gettext(perrorcode IN NUMBER) RETURN VARCHAR IS
	BEGIN
		FOR i IN (SELECT /*+ Result_Ca?he */
				   errtext
				  FROM   terror
				  WHERE  errcode = perrorcode)
		LOOP
			RETURN TRIM(i.errtext);
		END LOOP;
		RETURN debug.viewmaskdata(TRIM(SQLERRM(perrorcode)));
	END;

	PROCEDURE restoreerror
	
	 IS
	BEGIN
		serror.code  := saveerrorcode;
		serror.place := saveerrorplace;
		serror.text  := saveerrortext;
	END;

	PROCEDURE saveerror
	
	 IS
	BEGIN
		saveerrorcode  := serror.code;
		saveerrorplace := serror.place;
		saveerrortext  := serror.text;
	END;

	PROCEDURE seterror
	(
		perrorcode  IN NUMBER
	   ,perrorplace IN VARCHAR
	   ,perrortext  IN VARCHAR
	) IS
	BEGIN
		serror.code  := perrorcode;
		serror.text  := debug.viewmaskdata(nvl(perrortext, service.iif(SQLCODE != 0, SQLERRM, NULL)));
		serror.place := debug.viewmaskdata(perrorplace);
		traceerr(perrorcode, serror.place, serror.text);
	END;

	FUNCTION getcontext RETURN typecontextrec IS
	BEGIN
		RETURN serror;
	END;

	PROCEDURE putcontext
	(
		pcontext typecontextrec
	   ,pplace   VARCHAR := NULL
	) IS
	BEGIN
		trace('PutContext'
			 ,pplace || ' [' || pcontext.code || ', ' || pcontext.place || ', ' || pcontext.text || ']');
		serror := pcontext;
	END;

	PROCEDURE traceerr
	(
		pcode  IN NUMBER
	   ,pplace IN VARCHAR
	   ,ptext  IN VARCHAR
	) IS
	BEGIN
		IF tracer.getmode
		THEN
			IF ptext IS NOT NULL
			THEN
				tracer.traceerr(pcode, pplace, ptext);
			ELSE
				tracer.traceerr(pcode, pplace, gettext(pcode));
			END IF;
		END IF;
	END;

	PROCEDURE trace
	(
		pplace IN VARCHAR
	   ,ptext  IN VARCHAR
	) IS
	BEGIN
		IF tracer.getmode
		THEN
			tracer.trace('Err.' || pplace, ptext);
		END IF;
	END;

	PROCEDURE setnontracezeroerror(pnontrace BOOLEAN) IS
	BEGIN
		s.say('Error.SetNonTraceZeroError : set ' || htools.bool2str(pnontrace));
		snontracezeroerror := nvl(pnontrace, FALSE);
	END;

BEGIN

	serror.code := 0;

	saveerrorcode  := 0;
	saveerrorplace := NULL;
	saveerrortext  := NULL;
END;
/
