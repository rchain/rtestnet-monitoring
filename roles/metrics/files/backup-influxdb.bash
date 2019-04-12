#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail


remove_temporary_directory () {
    if [[ -n ${backup_dir:-} ]]; then
        rm --recursive --force "$backup_dir"
    fi
}


remove_tarball () {
    if [[ -n ${tarball_basename:-} ]]; then
        rm --recursive --force "$tarball_basename"
    fi

    remove_temporary_directory
}


main () {
    local container=$(docker ps --filter 'name=influxdb' --quiet)
    if [[ $container = *\ * ]]; then
        echo "Multiple containers matched: $container"
        return 1
    fi

    trap remove_temporary_directory EXIT
    backup_dir=$(mktemp --directory --tmpdir=/tmp/influxdb)

    local backup_dir_basename=$(basename "$backup_dir")
    docker exec "$container" influxd backup -portable -database testnet1_collectd "/tmp/$backup_dir_basename"

    tarball_basename="testnet1_collectd.tar"
    trap remove_tarball EXIT
    tar --create --verbose --directory="$backup_dir" --file="$tarball_basename" .

    gsutil cp "$tarball_basename" "gs://rchain-backups/testnet-influxdb/${tarball_basename}"

    curl --header "Content-Type: application/json" --request POST --data '{"host": "rtestnet-monitoring", "service": "influxdb-database-backup", "status": "0", "output": ""}' http://nagios.c.developer-222401.internal:6315/submit_result
}


main "$@"
