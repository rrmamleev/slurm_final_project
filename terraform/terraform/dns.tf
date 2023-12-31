resource "yandex_dns_zone" "this" {
  name             = "yelb-public-zone"
  zone             = "${var.YELB_APP_DNS_NAME}."
  public           = true
  private_networks = [yandex_vpc_network.this.id]
}

resource "yandex_dns_recordset" "this" {
  zone_id = yandex_dns_zone.this.id
  name    = "@"
  type    = "A"
  ttl     = 200
  data    = [yandex_vpc_address.this.external_ipv4_address.0.address]
}
