package purge;

# Füge dynamisch den Architektur-spezifischen Pfad hinzu
use Config;
use File::Spec;

BEGIN {
    my $archname = $Config{archname};
    my $vendorlib = File::Spec->catdir($Config{vendorlibexp}, $archname);
    push @INC, $vendorlib;
}

use nginx;

sub purge {
    # Ein Systembefehl wird ausgeführt, um den Cache zu leeren
    system "rm -rf /etc/nginx/cache/*";

    # HTTP_NO_CONTENT ist eine Konstante aus dem Nginx-Modul und bedeutet 204 No Content
    return HTTP_NO_CONTENT;
}

1;
__END__