set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_release=>'5.1.3.00.05'
,p_default_workspace_id=>10390063953384733491
,p_default_application_id=>115922
,p_default_owner=>'CITIEST'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/dynamic_action/mho_refresh_tree
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(27276911308767386240)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'MHO.REFRESH_TREE'
,p_display_name=>'Tree - Refresh'
,p_category=>'COMPONENT'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'type tree_rt is record (',
'    node_status     number',
'  , node_level      number',
'  , node_title      varchar2(4000)',
'  , node_icon       varchar2(4000)',
'  , node_value      varchar2(4000)',
'  , node_tooltip    varchar2(4000)',
'  , node_link       varchar2(4000)',
');',
'',
'type tree_tt is table of tree_rt index by pls_integer;',
'',
'g_has_identity    boolean default true;',
'g_root_count      number := 0;',
'  ',
'----------------------------------------------------------',
'-- function get_affected_region_id',
'----------------------------------------------------------',
'function get_affected_region_id (',
'  p_action_id in apex_application_page_da_acts.action_id%type',
') return apex_application_page_da_acts.affected_region_id%type',
'is',
'',
'  l_affected_region_id   apex_application_page_da_acts.affected_region_id%type;',
'',
'begin',
'',
'  select affected_region_id into l_affected_region_id',
'    from apex_application_page_da_acts',
'   where action_id = p_action_id;',
'',
'  return l_affected_region_id;',
'',
'end get_affected_region_id;',
'',
'------------------------------------------------------------',
'-- function get_data',
'------------------------------------------------------------   ',
'function get_data (',
'  p_region_id in number',
') return tree_tt',
'is',
'',
'  l_query           apex_application_page_trees.tree_query%type;',
'  l_source_result   apex_plugin_util.t_column_value_list2;',
'  l_tree_tab        tree_tt;',
'',
'  l_columns_count   constant number := 7;',
'',
'  begin',
'  ',
'  -- Get source query',
'  select tree_query into l_query',
'    from apex_application_page_trees',
'   where region_id = p_region_id;',
'',
'  -- Execute query',
'  l_source_result := apex_plugin_util.get_data2 (',
'      p_sql_statement     => l_query',
'    , p_min_columns       => l_columns_count',
'    , p_max_columns       => l_columns_count',
'    , p_component_name    => null',
'  );',
'',
'  -- loop trough all records and fill tabel in memory',
'  for idx in 1..l_source_result(1).value_list.count loop',
'  ',
'    l_tree_tab(idx).node_status   := l_source_result(1).value_list(idx).number_value;',
'    l_tree_tab(idx).node_level    := l_source_result(2).value_list(idx).number_value;',
'    l_tree_tab(idx).node_title    := apex_plugin_util.get_value_as_varchar2(l_source_result(3).data_type, l_source_result(3).value_list(idx));',
'    l_tree_tab(idx).node_icon     := apex_plugin_util.get_value_as_varchar2(l_source_result(4).data_type, l_source_result(4).value_list(idx));',
'    l_tree_tab(idx).node_value    := apex_plugin_util.get_value_as_varchar2(l_source_result(5).data_type, l_source_result(5).value_list(idx));',
'    l_tree_tab(idx).node_tooltip  := apex_plugin_util.get_value_as_varchar2(l_source_result(6).data_type, l_source_result(6).value_list(idx));',
'    l_tree_tab(idx).node_link     := apex_plugin_util.get_value_as_varchar2(l_source_result(7).data_type, l_source_result(7).value_list(idx));',
'    ',
'    if l_tree_tab(idx).node_value is null then',
'      g_has_identity := false;',
'    end if;',
'    ',
'    if l_tree_tab(idx).node_level = 1 then',
'      g_root_count := g_root_count + 1;',
'    end if;',
'  ',
'  end loop;',
'  ',
'  return l_tree_tab;',
'',
'end get_data;',
'',
'------------------------------------------------------------',
'-- procedure print_json',
'------------------------------------------------------------  ',
'procedure print_json (',
'  p_region_id in number',
') is',
'',
'  l_tree_tab        tree_tt;',
'  l_prev_node_level number := 1;',
'',
'begin',
'',
'  l_tree_tab := get_data(p_region_id);',
'  ',
'  apex_json.open_object;',
'  ',
'  apex_json.open_object(''config'');',
'  apex_json.write(''hasIdentity'', g_has_identity);',
'  apex_json.write(''rootAdded'', g_root_count > 1);  ',
'  apex_json.close_object;',
'  ',
'  apex_json.open_object(''data'');',
'  ',
'  if g_root_count > 1 then',
'  ',
'    apex_json.write(''id'', ''root0'');',
'    apex_json.write(''label'', ''root'');',
'    apex_json.open_array(''children'');',
'  ',
'  end if;',
'  ',
'  for idx in 1..l_tree_tab.count loop',
'  ',
'    -- close possible array nesting',
'    if l_tree_tab(idx).node_level < l_prev_node_level then',
'    ',
'      for nesting_idx in 1..(l_prev_node_level - l_tree_tab(idx).node_level) loop',
'        ',
'        apex_json.close_array;',
'        apex_json.close_object;',
'      ',
'      end loop;',
'    ',
'    end if;',
'    ',
'    l_prev_node_level := l_tree_tab(idx).node_level;',
'  ',
'    if not (g_root_count = 1 and l_tree_tab(idx).node_level = 1) then',
'        apex_json.open_object;',
'    end if;',
'    ',
'    apex_json.write(''id'', l_tree_tab(idx).node_value);',
'    apex_json.write(''label'', l_tree_tab(idx).node_title);',
'    apex_json.write(''link'', l_tree_tab(idx).node_link);',
'    apex_json.write(''tooltip'', l_tree_tab(idx).node_tooltip);',
'    ',
'    -- isleaf',
'    if l_tree_tab(idx).node_status = 0 then',
'    ',
'      apex_json.close_object;',
'  ',
'    else',
'    ',
'      apex_json.open_array(''children'');',
'      ',
'    end if;',
'  ',
'  end loop;',
'  ',
'  apex_json.close_all;',
'',
'end print_json;',
'',
'------------------------------------------------------------------------------',
'-- function render',
'------------------------------------------------------------------------------',
'function render(',
'  p_dynamic_action in apex_plugin.t_dynamic_action',
' ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result',
'is',
'  l_js                  varchar2(4000);',
'  l_result              apex_plugin.t_dynamic_action_render_result;',
'  ',
'  l_region_id           apex_application_page_da_acts.affected_region_id%type;',
'  ',
'  cursor c_plug(p_region_id   apex_application_page_regions.region_id%type) is',
'    select coalesce(static_id, ''R'' || region_id) region_id',
'         , attribute_01 tree_template',
'         , attribute_02 tree_click_action',
'         , attribute_03 tree_selected_node',
'         , attribute_04 show_hints',
'         , attribute_05 tree_hint_text',
'         , attribute_06 tree_static_id',
'         , attribute_07 tree_implementation',
'         , attribute_08 icon_type',
'         , init_javascript_code',
'      from apex_application_page_regions ',
'     where source_type_plugin_name = ''NATIVE_JSTREE''',
'       and region_id = p_region_id;',
'       ',
'  l_plug_rec  c_plug%rowtype;',
'',
'begin',
'',
'  apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin',
'                                       ,p_dynamic_action => p_dynamic_action);',
'                                       ',
'  apex_javascript.add_library (',
'    p_name                    => ''apexTreeView#MIN#''',
'  , p_directory               => p_plugin.file_prefix',
'  , p_check_to_add_minified   => false',
'  ); ',
'  ',
'  l_region_id := get_affected_region_id(p_dynamic_action.id);',
'  ',
'  open c_plug(l_region_id);',
'  fetch c_plug into l_plug_rec;',
'  close c_plug;',
'  ',
'  l_js :=',
'  q''[mho.apexTreeView.addInitConfig({',
'    regionId: "#REGION_ID#",',
'    treeId: "#TREE_ID#",',
'    treeAction: "#TREE_ACTION#",',
'    selectedNodeId: "#SELECTED_NODE_ID#",',
'    hasTooltips: #HAS_TOOLTIPS#,',
'    iconType: "#ICON_TYPE#"',
'  })]'';',
'  ',
'  l_js := replace(l_js,''#REGION_ID#'',l_plug_rec.region_id);',
'  l_js := replace(l_js,''#TREE_ID#'',coalesce(l_plug_rec.tree_static_id, ''tree'' || l_region_id));',
'  l_js := replace(l_js,''#TREE_ACTION#'',l_plug_rec.tree_click_action);',
'  l_js := replace(l_js,''#SELECTED_NODE_ID#'',l_plug_rec.tree_selected_node);',
'  l_js := replace(l_js,''#HAS_TOOLTIPS#'',case when l_plug_rec.show_hints != ''N'' then ''true'' else ''false'' end);',
'  l_js := replace(l_js,''#ICON_TYPE#'',l_plug_rec.icon_type);',
'  ',
'  apex_javascript.add_onload_code(p_code => l_js);',
'  ',
'  l_js :=',
'  q''[function() {',
'    mho.apexTreeView.refresh({',
'      da: this,',
'      ajaxIdentifier: "#AJAX_IDENTIFIER#",',
'      itemsToSubmit: "#ITEMS_TO_SUBMIT#"',
'    })',
'  }]'';',
'  ',
'  l_js := replace(l_js,''#AJAX_IDENTIFIER#'',apex_plugin.get_ajax_identifier);',
'  l_js := replace(l_js,''#ITEMS_TO_SUBMIT#'',apex_plugin_util.page_item_names_to_jquery(p_dynamic_action.attribute_01));',
'  ',
'  l_result.javascript_function := l_js;',
'  ',
'  return l_result;',
'',
'end render;',
'',
'------------------------------------------------------------------------------',
'-- function ajax',
'------------------------------------------------------------------------------',
'function ajax(',
'  p_dynamic_action in apex_plugin.t_dynamic_action',
' ,p_plugin         in apex_plugin.t_plugin',
') return apex_plugin.t_dynamic_action_ajax_result',
'is',
'',
'  l_result              apex_plugin.t_dynamic_action_ajax_result;',
'',
'begin',
'',
'  print_json(get_affected_region_id(p_dynamic_action.id));',
'',
'  return l_result;',
'  ',
'end ajax;'))
,p_api_version=>1
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_standard_attributes=>'REGION:REQUIRED:WAIT_FOR_RESULT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'How to use?',
'Specify the tree region in the affected element(s).'))
,p_version_identifier=>'1.0'
,p_about_url=>'https://github.com/mennooo/orclapex-treeview-refresh'
,p_files_version=>38
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(27276911484025386243)
,p_plugin_id=>wwv_flow_api.id(27276911308767386240)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Items to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C20617065782024202A2F0D0A77696E646F772E6D686F203D2077696E646F772E6D686F207C7C207B7D0D0A3B2866756E6374696F6E20286E616D65737061636529207B0D0A20202F2F205765206E65656420746F20657874656E64';
wwv_flow_api.g_varchar2_table(2) := '207468652074726565566965772077696467657420746F2072657475726E20746865206261736549640D0A2020242E7769646765742827617065782E7472656556696577272C20242E617065782E74726565566965772C207B0D0A202020206D686F4765';
wwv_flow_api.g_varchar2_table(3) := '744261736549643A2066756E6374696F6E202829207B0D0A20202020202072657475726E20746869732E6261736549640D0A202020207D0D0A20207D290D0A20202F2F204B65657020616C6C207472656520636F6E66696775726174696F6E7320696E20';
wwv_flow_api.g_varchar2_table(4) := '6D656D6F72792C2075736566756C206F6E206372656174696E672061206E657720696E7374616E63650D0A20207661722067436F6E66696775726174696F6E73203D205B5D0D0A0D0A202066756E6374696F6E207265667265736820286F7074696F6E73';
wwv_flow_api.g_varchar2_table(5) := '29207B0D0A202020202F2F20476574207468652077696467657420656C656D656E740D0A20202020766172207472656524203D206F7074696F6E732E64612E6166666563746564456C656D656E74732E66696E6428272E612D547265655669657727290D';
wwv_flow_api.g_varchar2_table(6) := '0A202020202F2F204765742074686520636F6E6669672066726F6D206D656D6F72792C206964656E74696669656420627920726567696F6E49640D0A2020202076617220636F6E666967203D2067436F6E66696775726174696F6E735B6F7074696F6E73';
wwv_flow_api.g_varchar2_table(7) := '2E64612E6166666563746564456C656D656E74732E666972737428292E617474722827696427295D0D0A202020202F2F20476574206E6577207472656520646174610D0A202020207661722070726F6D697365203D20617065782E7365727665722E706C';
wwv_flow_api.g_varchar2_table(8) := '7567696E286F7074696F6E732E616A61784964656E7469666965722C207B0D0A202020202020706167654974656D733A206F7074696F6E732E6974656D73546F5375626D69740D0A202020207D2C207B0D0A2020202020206C6F6164696E67496E646963';
wwv_flow_api.g_varchar2_table(9) := '61746F723A2074726565242C0D0A2020202020206C6F6164696E67496E64696361746F72506F736974696F6E3A202763656E7465726564270D0A202020207D290D0A0D0A202020207661722073656C65637465644E6F6465732C0D0A2020202020206578';
wwv_flow_api.g_varchar2_table(10) := '70616E6465644E6F6465734964730D0A0D0A202020202F2F20416674657220414A41582C207265667265736820747265650D0A2020202070726F6D6973652E646F6E652866756E6374696F6E20286461746129207B0D0A2020202020202F2F2057686174';
wwv_flow_api.g_varchar2_table(11) := '20746F20646F207768656E207472656520697320656D70747920616674657220726566726573680D0A20202020202069662028242E6973456D7074794F626A65637428646174612E646174612929207B0D0A202020202020202074726565242E74726967';
wwv_flow_api.g_varchar2_table(12) := '67657228276170657861667465727265667265736827290D0A2020202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C6261636B2C2066616C7365290D0A202020202020202074726565242E747265';
wwv_flow_api.g_varchar2_table(13) := '6556696577282764657374726F7927290D0A202020202020202072657475726E0D0A2020202020207D0D0A0D0A2020202020202F2F2043726561746520696E7374616E6365206F66207472656520696620697420646F6573206E6F742065786973740D0A';
wwv_flow_api.g_varchar2_table(14) := '2020202020206966202874726565242E6C656E677468203D3D3D203029207B0D0A2020202020202020617065782E7769646765742E747265652E696E697428636F6E6669672E7472656549642C207B7D2C20646174612E646174612C20636F6E6669672E';
wwv_flow_api.g_varchar2_table(15) := '74726565416374696F6E2C20636F6E6669672E73656C65637465644E6F646549642C20646174612E636F6E6669672E6861734964656E746974792C20646174612E636F6E6669672E726F6F7441646465642C20636F6E6669672E686173546F6F6C746970';
wwv_flow_api.g_varchar2_table(16) := '732C20636F6E6669672E69636F6E54797065290D0A2020202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C6261636B2C2066616C7365290D0A202020202020202072657475726E0D0A2020202020';
wwv_flow_api.g_varchar2_table(17) := '207D0D0A0D0A2020202020202F2F2049662074726565207374696C6C20657869737473207468656E207265667265736820646174610D0A202020202020766172206E6F646541646170746572203D2074726565242E747265655669657728276765744E6F';
wwv_flow_api.g_varchar2_table(18) := '64654164617074657227290D0A0D0A2020202020206E6F6465416461707465722E64617461203D20646174612E646174610D0A20202020202073656C65637465644E6F646573203D2074726565242E7472656556696577282767657453656C6563746564';
wwv_flow_api.g_varchar2_table(19) := '4E6F64657327290D0A202020202020657870616E6465644E6F646573496473203D2074726565242E747265655669657728276765744E6F64654164617074657227292E676574457870616E6465644E6F64654964732874726565242E7472656556696577';
wwv_flow_api.g_varchar2_table(20) := '28276D686F4765744261736549642729290D0A0D0A20202020202074726565242E747265655669657728277265667265736827290D0A0D0A202020202020657870616E6465644E6F6465734964732E666F72456163682866756E6374696F6E2028696429';
wwv_flow_api.g_varchar2_table(21) := '207B0D0A2020202020202020766172206E6F646524203D2074726565242E7472656556696577282766696E64272C207B0D0A2020202020202020202064657074683A202D312C0D0A2020202020202020202066696E64416C6C3A2066616C73652C0D0A20';
wwv_flow_api.g_varchar2_table(22) := '2020202020202020206D617463683A2066756E6374696F6E20286E6F646529207B0D0A20202020202020202020202072657475726E206E6F64652E6964203D3D3D2069640D0A202020202020202020207D0D0A20202020202020207D290D0A2020202020';
wwv_flow_api.g_varchar2_table(23) := '20202074726565242E74726565566965772827657870616E64272C206E6F646524290D0A2020202020207D290D0A0D0A20202020202073656C65637465644E6F6465732E6D61702866756E6374696F6E20286E6F646529207B0D0A202020202020202072';
wwv_flow_api.g_varchar2_table(24) := '657475726E2074726565242E7472656556696577282766696E64272C207B0D0A2020202020202020202064657074683A202D312C0D0A2020202020202020202066696E64416C6C3A2066616C73652C0D0A202020202020202020206D617463683A206675';
wwv_flow_api.g_varchar2_table(25) := '6E6374696F6E20286E6F646529207B0D0A20202020202020202020202072657475726E206E6F64652E6964203D3D3D206E6F64652E69640D0A202020202020202020207D0D0A20202020202020207D290D0A2020202020207D290D0A2020202020206966';
wwv_flow_api.g_varchar2_table(26) := '202873656C65637465644E6F6465732E6C656E677468203E203029207B0D0A202020202020202074726565242E7472656556696577282773657453656C65637465644E6F646573272C2073656C65637465644E6F6465732C2074727565290D0A20202020';
wwv_flow_api.g_varchar2_table(27) := '20207D0D0A0D0A20202020202074726565242E7472696767657228276170657861667465727265667265736827290D0A202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C6261636B2C2066616C73';
wwv_flow_api.g_varchar2_table(28) := '65290D0A202020207D290D0A20207D0D0A0D0A202066756E6374696F6E20616464496E6974436F6E6669672028636F6E66696729207B0D0A2020202067436F6E66696775726174696F6E735B636F6E6669672E726567696F6E49642E746F537472696E67';
wwv_flow_api.g_varchar2_table(29) := '28295D203D20636F6E6669670D0A20207D0D0A0D0A20206E616D6573706163652E617065785472656556696577203D207B0D0A20202020726566726573683A20726566726573682C0D0A20202020616464496E6974436F6E6669673A20616464496E6974';
wwv_flow_api.g_varchar2_table(30) := '436F6E6669670D0A20207D0D0A7D292877696E646F772E6D686F290D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(26915716552855528452)
,p_plugin_id=>wwv_flow_api.id(27276911308767386240)
,p_file_name=>'apexTreeView.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E6D686F3D77696E646F772E6D686F7C7C7B7D2C66756E6374696F6E2865297B66756E6374696F6E20742865297B76617220742C692C643D652E64612E6166666563746564456C656D656E74732E66696E6428222E612D54726565566965';
wwv_flow_api.g_varchar2_table(2) := '7722292C613D725B652E64612E6166666563746564456C656D656E74732E666972737428292E617474722822696422295D2C6E3D617065782E7365727665722E706C7567696E28652E616A61784964656E7469666965722C7B706167654974656D733A65';
wwv_flow_api.g_varchar2_table(3) := '2E6974656D73546F5375626D69747D2C7B6C6F6164696E67496E64696361746F723A642C6C6F6164696E67496E64696361746F72506F736974696F6E3A2263656E7465726564227D293B6E2E646F6E652866756E6374696F6E2872297B696628242E6973';
wwv_flow_api.g_varchar2_table(4) := '456D7074794F626A65637428722E64617461292972657475726E20642E7472696767657228226170657861667465727265667265736822292C617065782E64612E726573756D6528652E64612E726573756D6543616C6C6261636B2C2131292C766F6964';
wwv_flow_api.g_varchar2_table(5) := '20642E7472656556696577282264657374726F7922293B696628303D3D3D642E6C656E6774682972657475726E20617065782E7769646765742E747265652E696E697428612E7472656549642C7B7D2C722E646174612C612E74726565416374696F6E2C';
wwv_flow_api.g_varchar2_table(6) := '612E73656C65637465644E6F646549642C722E636F6E6669672E6861734964656E746974792C722E636F6E6669672E726F6F7441646465642C612E686173546F6F6C746970732C612E69636F6E54797065292C766F696420617065782E64612E72657375';
wwv_flow_api.g_varchar2_table(7) := '6D6528652E64612E726573756D6543616C6C6261636B2C2131293B766172206E3D642E747265655669657728226765744E6F64654164617074657222293B6E2E646174613D722E646174612C743D642E7472656556696577282267657453656C65637465';
wwv_flow_api.g_varchar2_table(8) := '644E6F64657322292C693D642E747265655669657728226765744E6F64654164617074657222292E676574457870616E6465644E6F646549647328642E747265655669657728226D686F4765744261736549642229292C642E7472656556696577282272';
wwv_flow_api.g_varchar2_table(9) := '65667265736822292C692E666F72456163682866756E6374696F6E2865297B76617220743D642E7472656556696577282266696E64222C7B64657074683A2D312C66696E64416C6C3A21312C6D617463683A66756E6374696F6E2874297B72657475726E';
wwv_flow_api.g_varchar2_table(10) := '20742E69643D3D3D657D7D293B642E74726565566965772822657870616E64222C74297D292C742E6D61702866756E6374696F6E2865297B72657475726E20642E7472656556696577282266696E64222C7B64657074683A2D312C66696E64416C6C3A21';
wwv_flow_api.g_varchar2_table(11) := '312C6D617463683A66756E6374696F6E2865297B72657475726E20652E69643D3D3D652E69647D7D297D292C742E6C656E6774683E302626642E7472656556696577282273657453656C65637465644E6F646573222C742C2130292C642E747269676765';
wwv_flow_api.g_varchar2_table(12) := '7228226170657861667465727265667265736822292C617065782E64612E726573756D6528652E64612E726573756D6543616C6C6261636B2C2131297D297D66756E6374696F6E20692865297B725B652E726567696F6E49642E746F537472696E672829';
wwv_flow_api.g_varchar2_table(13) := '5D3D657D242E7769646765742822617065782E7472656556696577222C242E617065782E74726565566965772C7B6D686F4765744261736549643A66756E6374696F6E28297B72657475726E20746869732E6261736549647D7D293B76617220723D5B5D';
wwv_flow_api.g_varchar2_table(14) := '3B652E6170657854726565566965773D7B726566726573683A742C616464496E6974436F6E6669673A697D7D2877696E646F772E6D686F293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(26915716802451528452)
,p_plugin_id=>wwv_flow_api.id(27276911308767386240)
,p_file_name=>'apexTreeView.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
