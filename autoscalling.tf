################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "read_replica_count" {
  count = var.replica_scale_enabled == "true" ? 1 : 0

  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = "cluster:${aws_rds_cluster.rds_cluster.id}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "autoscaling_read_replica_count" {
  count = var.replica_scale_enabled == "true" ? 1 : 0

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.read_replica_count[0].service_namespace
  scalable_dimension = aws_appautoscaling_target.read_replica_count[0].scalable_dimension
  resource_id        = aws_appautoscaling_target.read_replica_count[0].resource_id

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.replica_scale_in_cooldown
    scale_out_cooldown = var.replica_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.replica_scale_cpu : var.replica_scale_connections
  }

  depends_on = [aws_appautoscaling_target.read_replica_count]
}