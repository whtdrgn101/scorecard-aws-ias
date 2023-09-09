output "scorecard_database_hostname" {
    value = "${aws_db_instance.sc_db.endpoint}"
}