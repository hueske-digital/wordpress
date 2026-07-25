package purge;

use nginx;

# Das Cache-Verzeichnis wird atomar zur Seite geschoben (rename ist O(1)) und
# erst danach im Hintergrund geloescht. Zuvor lief hier ein synchrones
# "rm -rf", das den nginx-Worker fuer die gesamte Loeschdauer blockierte.
#
# Das abgesetzte rm haengt sich an PID 1 -- das ist vertretbar, weil ein Purge
# nach Deploys ausgeloest wird und nicht im Request-Pfad liegt. Der Pfad wird
# ausschliesslich aus Konstanten und Zahlen gebaut, enthaelt also keine
# Request-Daten.
#
# Hinweis: der Cache-Manager haelt die Metadaten weiter in der Shared-Memory-
# Zone. Eintraege, deren Dateien nun fehlen, werden als MISS behandelt und beim
# naechsten Durchlauf aus der Zone entfernt -- das max_size-Accounting ist bis
# dahin zu hoch, korrigiert sich aber selbst.

my $cache = '/tmp/cache';
my $seq   = 0;

sub purge {
    if ( -d $cache ) {
        my $trash = sprintf '%s.trash.%d.%d.%d', $cache, $$, time(), $seq++;
        rename( $cache, $trash ) or return HTTP_INTERNAL_SERVER_ERROR;
        system("rm -rf '$trash' &");
    }

    unless ( mkdir $cache, 0700 ) {
        # EEXIST ist harmlos (paralleler Purge), alles andere nicht: ohne
        # Verzeichnis schlagen saemtliche Cache-Schreibvorgaenge still fehl.
        return HTTP_INTERNAL_SERVER_ERROR unless -d $cache;
    }

    return HTTP_NO_CONTENT;
}

1;
__END__
