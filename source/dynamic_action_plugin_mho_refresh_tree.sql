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
'------------------------------------------------------------------------------',
'-- function render',
'------------------------------------------------------------------------------',
'function render(',
'  p_dynamic_action in apex_plugin.t_dynamic_action',
' ,p_plugin         in apex_plugin.t_plugin) return apex_plugin.t_dynamic_action_render_result',
'is',
'  l_js                  varchar2(4000);',
'  l_result              apex_plugin.t_dynamic_action_render_result;',
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
'  );    ',
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
'  l_static_url          apex_application_page_items.attribute_01%type := p_dynamic_action.attribute_01;',
'  l_result              apex_plugin.t_dynamic_action_ajax_result;',
'    ',
'  type tree_rt is record (',
'      node_status     number',
'    , node_level      number',
'    , node_title      varchar2(4000)',
'    , node_icon       varchar2(4000)',
'    , node_value      varchar2(4000)',
'    , node_tooltip    varchar2(4000)',
'    , node_link       varchar2(4000)',
'  );',
'  ',
'  type tree_tt is table of tree_rt index by pls_integer;',
'  ',
'  ----------------------------------------------------------',
'  -- function get_affected_region_id',
'  ----------------------------------------------------------',
'  function get_affected_region_id (',
'    p_action_id in apex_application_page_da_acts.action_id%type',
'  ) return apex_application_page_da_acts.affected_region_id%type',
'  is',
'  ',
'    l_affected_region_id   apex_application_page_da_acts.affected_region_id%type;',
'  ',
'  begin',
'  ',
'    select affected_region_id into l_affected_region_id',
'      from apex_application_page_da_acts',
'     where action_id = p_action_id;',
'  ',
'    return l_affected_region_id;',
'  ',
'  end get_affected_region_id;',
'  ',
'  ------------------------------------------------------------',
'  -- procedure print_json',
'  ------------------------------------------------------------  ',
'  procedure print_json (',
'    p_region_id in number',
'  ) is',
'  ',
'    l_tree_tab        tree_tt;',
'    l_prev_node_level number := 1;',
'',
'    g_columns_count constant number := 7;',
'    ',
'    ------------------------------------------------------------',
'    -- function get_data',
'    ------------------------------------------------------------   ',
'    function get_data (',
'      p_region_id in number',
'    ) return tree_tt',
'    is',
'    ',
'      l_query           apex_application_page_trees.tree_query%type;',
'      l_source_result   apex_plugin_util.t_column_value_list2;',
'      l_tree_tab        tree_tt;',
'    ',
'      begin',
'      ',
'      -- Get source query',
'      select tree_query into l_query',
'        from apex_application_page_trees',
'       where region_id = p_region_id;',
'    ',
'      -- Execute query',
'      l_source_result := apex_plugin_util.get_data2 (',
'          p_sql_statement     => l_query',
'        , p_min_columns       => g_columns_count',
'        , p_max_columns       => g_columns_count',
'        , p_component_name    => null',
'      );',
'    ',
'      -- loop trough all records and fill tabel in memory',
'      for idx in 1..l_source_result(1).value_list.count loop',
'      ',
'        l_tree_tab(idx).node_status   := l_source_result(1).value_list(idx).number_value;',
'        l_tree_tab(idx).node_level    := l_source_result(2).value_list(idx).number_value;',
'        l_tree_tab(idx).node_title    := apex_plugin_util.get_value_as_varchar2(l_source_result(3).data_type, l_source_result(3).value_list(idx));',
'        l_tree_tab(idx).node_icon     := apex_plugin_util.get_value_as_varchar2(l_source_result(4).data_type, l_source_result(4).value_list(idx));',
'        l_tree_tab(idx).node_value    := apex_plugin_util.get_value_as_varchar2(l_source_result(5).data_type, l_source_result(5).value_list(idx));',
'        l_tree_tab(idx).node_tooltip  := apex_plugin_util.get_value_as_varchar2(l_source_result(6).data_type, l_source_result(6).value_list(idx));',
'        l_tree_tab(idx).node_link     := apex_plugin_util.get_value_as_varchar2(l_source_result(7).data_type, l_source_result(7).value_list(idx));',
'      ',
'      end loop;',
'      ',
'      return l_tree_tab;',
'    ',
'    end get_data;',
'  ',
'  begin',
'  ',
'    l_tree_tab := get_data(p_region_id);',
'    ',
'    apex_json.open_object;',
'    ',
'    apex_json.write(''id'', ''root0'');',
'    apex_json.write(''label'', ''root'');',
'    apex_json.open_array(''children'');',
'    ',
'    for idx in 1..l_tree_tab.count loop',
'    ',
'      -- close possible array nesting',
'      if l_tree_tab(idx).node_level < l_prev_node_level then',
'      ',
'        for nesting_idx in 1..(l_prev_node_level - l_tree_tab(idx).node_level) loop',
'          ',
'          apex_json.close_array;',
'          apex_json.close_object;',
'        ',
'        end loop;',
'      ',
'      end if;',
'      ',
'      l_prev_node_level := l_tree_tab(idx).node_level;',
'    ',
'      apex_json.open_object;',
'      apex_json.write(''id'', l_tree_tab(idx).node_value);',
'      apex_json.write(''label'', l_tree_tab(idx).node_title);',
'      apex_json.write(''link'', l_tree_tab(idx).node_link);',
'      apex_json.write(''tooltip'', l_tree_tab(idx).node_tooltip);',
'      ',
'      -- isleaf',
'      if l_tree_tab(idx).node_status = 0 then',
'      ',
'        apex_json.close_object;',
'    ',
'      else',
'      ',
'        apex_json.open_array(''children'');',
'        ',
'      end if;',
'    ',
'    end loop;',
'    ',
'    apex_json.close_all;',
'  ',
'  end print_json;',
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
,p_files_version=>13
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
wwv_flow_api.g_varchar2_table(1) := '2F2A20676C6F62616C20617065782024202A2F0D0A77696E646F772E6D686F203D2077696E646F772E6D686F207C7C207B7D0D0A3B2866756E6374696F6E20286E616D65737061636529207B0D0A202066756E6374696F6E207265667265736820286F70';
wwv_flow_api.g_varchar2_table(2) := '74696F6E7329207B0D0A20202020766172207472656524203D206F7074696F6E732E64612E6166666563746564456C656D656E74732E66696E6428272E612D547265655669657727290D0A20202020766172206E6F646541646170746572203D20747265';
wwv_flow_api.g_varchar2_table(3) := '65242E747265655669657728276765744E6F64654164617074657227290D0A202020207661722070726F6D697365203D20617065782E7365727665722E706C7567696E286F7074696F6E732E616A61784964656E7469666965722C207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(4) := '20706167654974656D733A206F7074696F6E732E6974656D73546F5375626D69740D0A202020207D2C207B0D0A2020202020206C6F6164696E67496E64696361746F723A2074726565242C0D0A2020202020206C6F6164696E67496E64696361746F7250';
wwv_flow_api.g_varchar2_table(5) := '6F736974696F6E3A202763656E7465726564270D0A202020207D290D0A0D0A2020202076617220657870616E6465644E6F6465732C0D0A20202020202073656C65637465644E6F6465730D0A0D0A2020202070726F6D6973652E646F6E652866756E6374';
wwv_flow_api.g_varchar2_table(6) := '696F6E20286461746129207B0D0A2020202020206E6F6465416461707465722E64617461203D20646174610D0A202020202020657870616E6465644E6F646573203D2074726565242E66696E6428272E69732D636F6C6C61707369626C6527292E746F41';
wwv_flow_api.g_varchar2_table(7) := '7272617928290D0A20202020202073656C65637465644E6F646573203D2074726565242E7472656556696577282767657453656C656374696F6E27292E746F417272617928290D0A0D0A202020202020657870616E6465644E6F646573203D2065787061';
wwv_flow_api.g_varchar2_table(8) := '6E6465644E6F6465732E6D61702866756E6374696F6E20286E6F646529207B0D0A202020202020202072657475726E20272327202B2024286E6F6465292E617474722827696427290D0A2020202020207D290D0A20202020202073656C65637465644E6F';
wwv_flow_api.g_varchar2_table(9) := '646573203D2073656C65637465644E6F6465732E6D61702866756E6374696F6E20286E6F646529207B0D0A202020202020202072657475726E20272327202B2024286E6F6465292E706172656E7428292E617474722827696427290D0A2020202020207D';
wwv_flow_api.g_varchar2_table(10) := '290D0A0D0A20202020202074726565242E747265655669657728277265667265736827290D0A0D0A202020202020657870616E6465644E6F6465732E666F72456163682866756E6374696F6E20286E6F646529207B0D0A20202020202020207472656524';
wwv_flow_api.g_varchar2_table(11) := '2E74726565566965772827657870616E64272C2024286E6F646529290D0A2020202020207D290D0A0D0A20202020202074726565242E7472656556696577282773657453656C656374696F6E272C20242873656C65637465644E6F6465732E6A6F696E28';
wwv_flow_api.g_varchar2_table(12) := '272C2729292C2074727565290D0A0D0A20202020202074726565242E7472696767657228276170657861667465727265667265736827290D0A202020202020617065782E64612E726573756D65286F7074696F6E732E64612E726573756D6543616C6C62';
wwv_flow_api.g_varchar2_table(13) := '61636B2C2066616C7365290D0A202020207D290D0A20207D0D0A0D0A20206E616D6573706163652E617065785472656556696577203D207B0D0A20202020726566726573683A20726566726573680D0A20207D0D0A7D292877696E646F772E6D686F290D';
wwv_flow_api.g_varchar2_table(14) := '0A';
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
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E6D686F3D77696E646F772E6D686F7C7C7B7D2C66756E6374696F6E2865297B66756E6374696F6E20742865297B76617220742C722C693D652E64612E6166666563746564456C656D656E74732E66696E6428222E612D54726565566965';
wwv_flow_api.g_varchar2_table(2) := '7722292C6E3D692E747265655669657728226765744E6F64654164617074657222292C613D617065782E7365727665722E706C7567696E28652E616A61784964656E7469666965722C7B706167654974656D733A652E6974656D73546F5375626D69747D';
wwv_flow_api.g_varchar2_table(3) := '2C7B6C6F6164696E67496E64696361746F723A692C6C6F6164696E67496E64696361746F72506F736974696F6E3A2263656E7465726564227D293B612E646F6E652866756E6374696F6E2861297B6E2E646174613D612C743D692E66696E6428222E6973';
wwv_flow_api.g_varchar2_table(4) := '2D636F6C6C61707369626C6522292E746F417272617928292C723D692E7472656556696577282267657453656C656374696F6E22292E746F417272617928292C743D742E6D61702866756E6374696F6E2865297B72657475726E2223222B242865292E61';
wwv_flow_api.g_varchar2_table(5) := '7474722822696422297D292C723D722E6D61702866756E6374696F6E2865297B72657475726E2223222B242865292E706172656E7428292E617474722822696422297D292C692E747265655669657728227265667265736822292C742E666F7245616368';
wwv_flow_api.g_varchar2_table(6) := '2866756E6374696F6E2865297B692E74726565566965772822657870616E64222C24286529297D292C692E7472656556696577282273657453656C656374696F6E222C2428722E6A6F696E28222C2229292C2130292C692E747269676765722822617065';
wwv_flow_api.g_varchar2_table(7) := '7861667465727265667265736822292C617065782E64612E726573756D6528652E64612E726573756D6543616C6C6261636B2C2131297D297D652E6170657854726565566965773D7B726566726573683A747D7D2877696E646F772E6D686F293B';
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
