use Module::Build;
Module::Build->new(
    module_name => 'Net::SS::Client',
    license     => 'perl',
    requires => {
        'Moo' => '1.002000',
    },
    configure_requires => { 'Module::Build' => 0.38 },
)->create_build_script;

