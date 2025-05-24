create_ip -name package_ip -vendor your.company -library user -version 1.0 \
          -module_name eid_reflex
set_property X_INTERFACE_MODE acc eid_reflex/*
save_ip
