# Oracle APEX Dynamic Action Plugin - APEX TreeView Refresh

This is a plugin to make the APEX 5.0 tree refreshable.

## Prerequisite
- APEX 5.0 or higher

## Install
- Import plugin file "dynamic_action_plugin_mho_refresh_tree.sql" from source directory into your application
- (Optional) Deploy the JS from "server" directory on your webserver and change the "File Prefix" to webservers folder.

## How to use
- Create a tree region
- Assign a static ID to the tree region

### In your Tree Source Statement
Do not use `apex_page.get_url` to create links per node. Only `apex_util.prepare_url` has support for setting the `p_triggering_element` explicitly.

Example
```
apex_util.prepare_url(<YOUR_LINK>, p_triggering_element => 'apex.jQuery("#<YOUR_STATIC_REGION_ID>")')
```

## Demo Application
<https://apex.oracle.com/pls/apex/f?p=115922:2>
