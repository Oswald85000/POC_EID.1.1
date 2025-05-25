ipx::package_project -root_dir [pwd] -vendor your.company -library user -taxonomy /UserIP -module_name eid_reflex
ipx::add_files [pwd]/../src/eid_reflex.v
ipx::create_xgui_files
ipx::save_core
