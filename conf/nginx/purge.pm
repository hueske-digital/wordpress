package purge;

use nginx;

sub purge {
    system "rm -rf /etc/nginx/cache/*";
    return HTTP_NO_CONTENT;
}

1;
__END__