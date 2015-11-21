# plugin.sh - DevStack plugin.sh dispatch script template

function install_ceilosca {
   echo "In install_ceilosca"
}

function init_ceilosca {
   echo "In init_ceilosca"
   get_or_add_user_project_role "monasca-user" "ceilometer" $SERVICE_TENANT_NAME
}

function configure_ceilosca {
    echo "In configure_ceilosca"
    sudo mkdir -p /etc/ceilometer
    sudo chown $CEILOSCA_USER /etc/ceilometer
    for ceilosca_conf_file in $CEILOSCA_CONF_FILES
    do
        # source file and dest file names are separated with :
        source_file=`awk -F':' '{print $1}' <<< $ceilosca_conf_file`
        dest_file=`awk -F':' '{print $2}' <<< $ceilosca_conf_file`
        if [ -z $dest_file ]; then
            dest_file=$source_file
        fi
        cp $CEILOSCA_DIR/etc/ceilometer/$source_file /etc/ceilometer/$dest_file
    done

    iniset $CEILOMETER_CONF database metering_connection monasca://$MONASCA_API_URL
}

function install_ceilometer {
    for ceilosca_file in $CEILOSCA_FILES
    do
        # source file and dest file names are separated with :
        source_file=`awk -F':' '{print $1}' <<< $ceilosca_file`
        dest_file=`awk -F':' '{print $2}' <<< $ceilosca_file`
        if [ -z $dest_file ]; then
            dest_file=$source_file
        fi

        cp $CEILOSCA_DIR/ceilosca/$source_file $CEILOMETER_DIR/$dest_file
    done

    if ! grep -q "python-monascaclient" $CEILOMETER_DIR/requirements.txt; then
        sudo bash -c "echo python-monascaclient >> $CEILOMETER_DIR/requirements.txt"
    fi

}

# check for service enabled
if is_service_enabled ceilosca; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # Set up system services
        echo_summary "Configuring system services ceilosca"
        install_ceilometer


    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # Perform installation of service source
        echo_summary "Installing ceilosca"
        install_ceilosca

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        echo_summary "Configuring ceilosca"
        configure_ceilosca

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        # Initialize and start the template service
        echo_summary "Initializing ceilosca"
        init_ceilosca
    fi

    if [[ "$1" == "unstack" ]]; then
        # Shut down template services
        # no-op
        :
    fi

    if [[ "$1" == "clean" ]]; then
        # Remove state and transient data
        # Remember clean.sh first calls unstack.sh
        # no-op
        :
    fi
fi
