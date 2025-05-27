# Configuração dos dashboards segmentados do Grafana por stakeholder
# Implementa estratégia de observabilidade especializada para diferentes audiências

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    # =========================================================================
    # 1. DASHBOARD PRINCIPAL - MLSecOps Overview
    # Visão geral para todos os stakeholders com navegação para dashboards específicos
    # =========================================================================
    "01-mlsecops-overview.json" = jsonencode({
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": {
              "type": "grafana",
              "uid": "-- Grafana --"
            },
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "id": null,
      "links": [
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "🔧 ML Engineers Dashboard",
          "tooltip": "Métricas técnicas detalhadas para engenheiros de ML",
          "type": "dashboards",
          "url": "/d/ml-engineers/ml-engineers-dashboard"
        },
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "📋 Compliance Dashboard",
          "tooltip": "Conformidade BCB 403 e métricas regulatórias",
          "type": "dashboards",
          "url": "/d/compliance-risk/compliance-risk-dashboard"
        },
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "📊 Executive Dashboard",
          "tooltip": "KPIs de negócio e métricas estratégicas",
          "type": "dashboards",
          "url": "/d/executive/executive-dashboard"
        }
      ],
      "liveNow": false,
      "panels": [
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 1,
          "panels": [],
          "title": "🎯 Status Geral do Sistema - MLSecOps Fraudes Pix",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 2,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 1
          },
          "id": 2,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total[1m])) by (result)",
              "legendFormat": "{{result}}",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📈 Taxa de Transações Processadas",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.001
                  },
                  {
                    "color": "red",
                    "value": 0.005
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 1
          },
          "id": 3,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total{result=\"fraude\"}[5m])) / sum(rate(ml_predictions_total[5m]))",
              "legendFormat": "Taxa de Fraude",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🚨 Taxa de Detecção de Fraudes",
          "type": "gauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 9
          },
          "id": 4,
          "panels": [],
          "title": "🔍 Qualidade do Modelo e Performance",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 16,
            "x": 0,
            "y": 10
          },
          "id": 5,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_precision{model_version=\"1.0\", model_type=\"xgboost\"}",
              "legendFormat": "Precision",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_recall{model_version=\"1.0\", model_type=\"xgboost\"}",
              "hide": false,
              "legendFormat": "Recall",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_f1_score{model_version=\"1.0\", model_type=\"xgboost\"}",
              "hide": false,
              "legendFormat": "F1-Score",
              "range": true,
              "refId": "C"
            }
          ],
          "title": "🎯 Métricas de Qualidade do Modelo",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.05
                  },
                  {
                    "color": "red",
                    "value": 0.1
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 16,
            "y": 10
          },
          "id": 6,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_drift_score{feature_set=\"base\", model_version=\"1.0\"}",
              "legendFormat": "Drift Score",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "⚠️ Score de Drift",
          "type": "gauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "id": 7,
          "panels": [],
          "title": "🔒 Status de Segurança e Integrações",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "0": {
                      "color": "red",
                      "index": 0,
                      "text": "Falha"
                    },
                    "1": {
                      "color": "green",
                      "index": 1,
                      "text": "Operacional"
                    }
                  },
                  "type": "value"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 0,
            "y": 19
          },
          "id": 8,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "dict_integration_status{operation_type=\"query\"}",
              "legendFormat": "DICT Consulta",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🔗 Status DICT",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 1
                  },
                  {
                    "color": "red",
                    "value": 5
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 8,
            "y": 19
          },
          "id": 9,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "expr": "sum(security_critical_issues)",
              "legendFormat": "Issues Críticos",
              "refId": "A"
            }
          ],
          "title": "🚨 Alertas Segurança",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.85
                  },
                  {
                    "color": "red",
                    "value": 0.75
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 16,
            "y": 19
          },
          "id": 10,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"overall\"}",
              "legendFormat": "Compliance BCB 403",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📋 Compliance BCB 403",
          "type": "gauge"
        }
      ],
      "refresh": "10s",
      "schemaVersion": 37,
      "style": "dark",
      "tags": [
        "mlsecops",
        "overview",
        "fraudes",
        "pix"
      ],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-30m",
        "to": "now"
      },
      "timepicker": {},
      "timezone": "",
      "title": "MLSecOps - Overview Principal",
      "uid": "mlsecops-overview",
      "version": 1,
      "weekStart": ""
    }),

    # =========================================================================
    # 2. DASHBOARD PARA ENGENHEIROS DE ML
    # Métricas técnicas detalhadas para troubleshooting e otimização
    # =========================================================================
    "02-ml-engineers-dashboard.json" = jsonencode({
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": {
              "type": "grafana",
              "uid": "-- Grafana --"
            },
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "id": null,
      "links": [
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": false,
          "title": "← Voltar ao Overview",
          "tooltip": "Dashboard principal MLSecOps",
          "type": "dashboards",
          "url": "/d/mlsecops-overview/mlsecops-overview-principal"
        },
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "📋 Ver Compliance",
          "tooltip": "Dashboard de conformidade regulatória",
          "type": "dashboards",
          "url": "/d/compliance-risk/compliance-risk-dashboard"
        }
      ],
      "liveNow": false,
      "panels": [
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 1,
          "panels": [],
          "title": "🔧 Performance e Latência do Sistema",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "s"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 1
          },
          "id": 2,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "histogram_quantile(0.95, sum(rate(inference_latency_seconds_bucket[5m])) by (le))",
              "legendFormat": "p95",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "histogram_quantile(0.90, sum(rate(inference_latency_seconds_bucket[5m])) by (le))",
              "hide": false,
              "legendFormat": "p90",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "histogram_quantile(0.50, sum(rate(inference_latency_seconds_bucket[5m])) by (le))",
              "hide": false,
              "legendFormat": "p50",
              "range": true,
              "refId": "C"
            }
          ],
          "title": "⚡ Latência de Inferência (Percentis)",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 1
          },
          "id": 3,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total[1m])) by (model_version)",
              "legendFormat": "{{model_version}}",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🚀 Throughput por Versão do Modelo",
          "type": "timeseries"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 9
          },
          "id": 4,
          "panels": [],
          "title": "📊 Detecção de Drift e Qualidade dos Dados",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 15,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 2,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "line"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.05
                  },
                  {
                    "color": "red",
                    "value": 0.1
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 16,
            "x": 0,
            "y": 10
          },
          "id": 5,
          "options": {
            "legend": {
              "calcs": ["last", "max"],
              "displayMode": "table",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_drift_score{feature_set=\"transaction\", model_version=\"1.0\"}",
              "legendFormat": "Drift Transacional",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_drift_score{feature_set=\"behavioral\", model_version=\"1.0\"}",
              "legendFormat": "Drift Comportamental",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_drift_score{feature_set=\"network\", model_version=\"1.0\"}",
              "legendFormat": "Drift de Rede",
              "range": true,
              "refId": "C"
            }
          ],
          "title": "📈 Drift por Conjunto de Features",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 10
                  },
                  {
                    "color": "red",
                    "value": 100
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 16,
            "y": 10
          },
          "id": 6,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(data_validation_errors_total[5m])) * 3600",
              "legendFormat": "Erros/hora",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "⚠️ Erros de Validação de Dados",
          "type": "stat"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "id": 7,
          "panels": [],
          "title": "🎯 Análise Detalhada de Modelos",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 0,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 2,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 19
          },
          "id": 8,
          "options": {
            "legend": {
              "calcs": ["last", "mean"],
              "displayMode": "table",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_precision{model_type=\"xgboost\"}",
              "legendFormat": "XGBoost Precision",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_precision{model_type=\"isolation_forest\"}",
              "legendFormat": "Isolation Forest Precision",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_precision{model_type=\"neural_network\"}",
              "legendFormat": "Neural Network Precision",
              "range": true,
              "refId": "C"
            }
          ],
          "title": "🎯 Precision por Tipo de Modelo",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 0,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 2,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "auto",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 19
          },
          "id": 9,
          "options": {
            "legend": {
              "calcs": ["last", "mean"],
              "displayMode": "table",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_recall{model_type=\"xgboost\"}",
              "legendFormat": "XGBoost Recall",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_recall{model_type=\"isolation_forest\"}",
              "legendFormat": "Isolation Forest Recall",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_recall{model_type=\"neural_network\"}",
              "legendFormat": "Neural Network Recall",
              "range": true,
              "refId": "C"
            }
          ],
          "title": "🔍 Recall por Tipo de Modelo",
          "type": "timeseries"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 27
          },
          "id": 10,
          "panels": [],
          "title": "🚀 Recursos e Infraestrutura",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 1,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "percent"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 28
          },
          "id": 11,
          "options": {
            "legend": {
              "calcs": [],
              "displayMode": "list",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "single",
              "sort": "none"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "100 * (1 - avg(rate(node_cpu_seconds_total{mode=\"idle\"}[5m])))",
              "legendFormat": "CPU Usage",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "100 * (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes))",
              "legendFormat": "Memory Usage",
              "range": true,
              "refId": "B"
            }
          ],
          "title": "💻 Utilização de Recursos do Cluster",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 5
                  },
                  {
                    "color": "red",
                    "value": 10
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 28
          },
          "id": 12,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "kube_pod_container_status_restarts_total",
              "legendFormat": "Pod Restarts",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🔄 Reinicializações de Pods",
          "type": "stat"
        }
      ],
      "refresh": "5s",
      "schemaVersion": 37,
      "style": "dark",
      "tags": [
        "mlsecops",
        "engineering",
        "technical",
        "ml"
      ],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-1h",
        "to": "now"
      },
      "timepicker": {},
      "timezone": "",
      "title": "ML Engineers - Dashboard Técnico",
      "uid": "ml-engineers",
      "version": 1,
      "weekStart": ""
    }),
    # =========================================================================
    # 3. DASHBOARD DE COMPLIANCE E RISK
    # Focado na conformidade com a Resolução BCB 403 e métricas regulatórias
    # =========================================================================
    "03-compliance-risk-dashboard.json" = jsonencode({
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": {
              "type": "grafana",
              "uid": "-- Grafana --"
            },
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "id": null,
      "links": [
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": false,
          "title": "← Voltar ao Overview",
          "tooltip": "Dashboard principal MLSecOps",
          "type": "dashboards",
          "url": "/d/mlsecops-overview/mlsecops-overview-principal"
        },
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "🔧 Ver Dashboard Técnico",
          "tooltip": "Métricas técnicas para engenheiros de ML",
          "type": "dashboards",
          "url": "/d/ml-engineers/ml-engineers-dashboard"
        }
      ],
      "liveNow": false,
      "panels": [
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 1,
          "panels": [],
          "title": "📋 Conformidade Resolução BCB nº 403/2024",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "from": 0.95,
                    "result": {
                      "color": "green",
                      "index": 0,
                      "text": "Conforme"
                    },
                    "to": 1
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0.85,
                    "result": {
                      "color": "yellow",
                      "index": 1,
                      "text": "Atenção"
                    },
                    "to": 0.95
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0,
                    "result": {
                      "color": "red",
                      "index": 2,
                      "text": "Não Conforme"
                    },
                    "to": 0.85
                  },
                  "type": "range"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.85
                  },
                  {
                    "color": "green",
                    "value": 0.95
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 0,
            "y": 1
          },
          "id": 2,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"overall\"}",
              "legendFormat": "Score Geral",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📊 Score Geral de Conformidade BCB 403",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.85
                  },
                  {
                    "color": "green",
                    "value": 0.95
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 16,
            "x": 8,
            "y": 1
          },
          "id": 3,
          "options": {
            "displayMode": "list",
            "minVizHeight": 10,
            "minVizWidth": 0,
            "orientation": "horizontal",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showUnfilled": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"89\"}",
              "legendFormat": "Art. 89 - Monitoramento Tempo Real",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"91\"}",
              "legendFormat": "Art. 91 - Detecção de Anomalias",
              "range": true,
              "refId": "B"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"93\"}",
              "legendFormat": "Art. 93 - Segurança de Dados",
              "range": true,
              "refId": "C"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"94\"}",
              "legendFormat": "Art. 94 - Documentação Sistema",
              "range": true,
              "refId": "D"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"95\"}",
              "legendFormat": "Art. 95 - Auditoria e Rastreabilidade",
              "range": true,
              "refId": "E"
            }
          ],
          "title": "📑 Conformidade por Artigo da BCB 403",
          "type": "bargauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 9
          },
          "id": 4,
          "panels": [],
          "title": "🔍 Explicabilidade e Transparência do Modelo",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "from": 0.8,
                    "result": {
                      "color": "green",
                      "index": 0,
                      "text": "Excelente"
                    },
                    "to": 1
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0.6,
                    "result": {
                      "color": "yellow",
                      "index": 1,
                      "text": "Adequado"
                    },
                    "to": 0.8
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0,
                    "result": {
                      "color": "red",
                      "index": 2,
                      "text": "Insuficiente"
                    },
                    "to": 0.6
                  },
                  "type": "range"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.6
                  },
                  {
                    "color": "green",
                    "value": 0.8
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 10
          },
          "id": 5,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_explainability_score{model_version=\"1.0\", model_type=\"xgboost\"}",
              "legendFormat": "Score Explicabilidade",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🔍 Score de Explicabilidade do Modelo",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 100
                  },
                  {
                    "color": "red",
                    "value": 1000
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 10
          },
          "id": 6,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(increase(model_explanations_generated_total[24h]))",
              "legendFormat": "Explicações Geradas (24h)",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📄 Explicações Geradas nas Últimas 24h",
          "type": "stat"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "id": 7,
          "panels": [],
          "title": "🔒 Auditoria e Integridade de Dados",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "0": {
                      "color": "red",
                      "index": 0,
                      "text": "Comprometida"
                    },
                    "1": {
                      "color": "green",
                      "index": 1,
                      "text": "Íntegra"
                    }
                  },
                  "type": "value"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 0,
            "y": 19
          },
          "id": 8,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "audit_log_integrity",
              "legendFormat": "Integridade Logs",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🔐 Integridade dos Logs de Auditoria",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "0": {
                      "color": "red",
                      "index": 0,
                      "text": "Não Conforme"
                    },
                    "1": {
                      "color": "green",
                      "index": 1,
                      "text": "Conforme"
                    }
                  },
                  "type": "value"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "green",
                    "value": 1
                  }
                ]
              }
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 8,
            "y": 19
          },
          "id": 9,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "data_retention_compliance",
              "legendFormat": "Retenção de Dados",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📅 Conformidade Retenção de Dados",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 5
                  },
                  {
                    "color": "red",
                    "value": 15
                  }
                ]
              },
              "unit": "s"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 8,
            "x": 16,
            "y": 19
          },
          "id": 10,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "regulatory_response_time_seconds{request_type=\"bcb_inquiry\"}",
              "legendFormat": "Tempo Resposta BCB",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "⏱️ Tempo de Resposta a Solicitações BCB",
          "type": "stat"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 25
          },
          "id": 11,
          "panels": [],
          "title": "🚨 Gestão de Riscos e Alertas Regulatórios",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 2,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "line"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 0.005
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 16,
            "x": 0,
            "y": 26
          },
          "id": 12,
          "options": {
            "legend": {
              "calcs": ["last", "max"],
              "displayMode": "table",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total{result=\"fraude\"}[10m])) / sum(rate(ml_predictions_total[10m]))",
              "legendFormat": "Taxa de Fraude Detectada",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(false_positive_alerts_total[10m])) / sum(rate(ml_predictions_total[10m]))",
              "legendFormat": "Taxa de Falsos Positivos",
              "range": true,
              "refId": "B"
            }
          ],
          "title": "📈 Evolução das Taxas de Detecção e Falsos Positivos",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 5
                  },
                  {
                    "color": "red",
                    "value": 20
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 16,
            "y": 26
          },
          "id": 13,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(increase(regulatory_alerts_total{severity=\"critical\"}[24h]))",
              "legendFormat": "Alertas Críticos (24h)",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🚨 Alertas Regulatórios Críticos (24h)",
          "type": "stat"
        }
      ],
      "refresh": "30s",
      "schemaVersion": 37,
      "style": "dark",
      "tags": [
        "mlsecops",
        "compliance",
        "bcb403",
        "regulatory"
      ],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-4h",
        "to": "now"
      },
      "timepicker": {},
      "timezone": "",
      "title": "Compliance & Risk - BCB 403",
      "uid": "compliance-risk",
      "version": 1,
      "weekStart": ""
    }),
    # =========================================================================
    # 4. DASHBOARD EXECUTIVO
    # KPIs de alto nível e métricas de business value para executivos
    # =========================================================================
    "04-executive-dashboard.json" = jsonencode({
      "annotations": {
        "list": [
          {
            "builtIn": 1,
            "datasource": {
              "type": "grafana",
              "uid": "-- Grafana --"
            },
            "enable": true,
            "hide": true,
            "iconColor": "rgba(0, 211, 255, 1)",
            "name": "Annotations & Alerts",
            "target": {
              "limit": 100,
              "matchAny": false,
              "tags": [],
              "type": "dashboard"
            },
            "type": "dashboard"
          }
        ]
      },
      "editable": true,
      "fiscalYearStartMonth": 0,
      "graphTooltip": 0,
      "id": null,
      "links": [
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": false,
          "title": "← Voltar ao Overview",
          "tooltip": "Dashboard principal MLSecOps",
          "type": "dashboards",
          "url": "/d/mlsecops-overview/mlsecops-overview-principal"
        },
        {
          "asDropdown": false,
          "icon": "external link",
          "includeVars": false,
          "keepTime": false,
          "tags": [],
          "targetBlank": true,
          "title": "📋 Ver Compliance Detalhado",
          "tooltip": "Dashboard de conformidade regulatória",
          "type": "dashboards",
          "url": "/d/compliance-risk/compliance-risk-dashboard"
        }
      ],
      "liveNow": false,
      "panels": [
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 0
          },
          "id": 1,
          "panels": [],
          "title": "💰 Impacto Financeiro e ROI do Sistema",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 100000
                  },
                  {
                    "color": "red",
                    "value": 500000
                  }
                ]
              },
              "unit": "currencyBRL"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 0,
            "y": 1
          },
          "id": 2,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(increase(fraud_prevented_value_brl[24h]))",
              "legendFormat": "Valor Protegido (24h)",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "💵 Valor Protegido contra Fraudes (24h)",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 5000000
                  },
                  {
                    "color": "red",
                    "value": 10000000
                  }
                ]
              },
              "unit": "currencyBRL"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 8,
            "y": 1
          },
          "id": 3,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(increase(fraud_prevented_value_brl[30d]))",
              "legendFormat": "Valor Acumulado (30d)",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "💰 Valor Acumulado Protegido (30 dias)",
          "type": "stat"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 3
                  },
                  {
                    "color": "green",
                    "value": 5
                  }
                ]
              },
              "unit": "none"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 16,
            "y": 1
          },
          "id": 4,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "mlsecops_roi_ratio",
              "legendFormat": "ROI do Sistema",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📊 ROI do Sistema MLSecOps",
          "type": "gauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 9
          },
          "id": 5,
          "panels": [],
          "title": "📈 KPIs Operacionais Estratégicos",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "palette-classic"
              },
              "custom": {
                "axisCenteredZero": false,
                "axisColorMode": "text",
                "axisLabel": "",
                "axisPlacement": "auto",
                "barAlignment": 0,
                "drawStyle": "line",
                "fillOpacity": 10,
                "gradientMode": "none",
                "hideFrom": {
                  "legend": false,
                  "tooltip": false,
                  "viz": false
                },
                "lineInterpolation": "linear",
                "lineWidth": 3,
                "pointSize": 5,
                "scaleDistribution": {
                  "type": "linear"
                },
                "showPoints": "never",
                "spanNulls": false,
                "stacking": {
                  "group": "A",
                  "mode": "none"
                },
                "thresholdsStyle": {
                  "mode": "off"
                }
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "red",
                    "value": 80
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 16,
            "x": 0,
            "y": 10
          },
          "id": 6,
          "options": {
            "legend": {
              "calcs": ["last", "mean"],
              "displayMode": "table",
              "placement": "bottom",
              "showLegend": true
            },
            "tooltip": {
              "mode": "multi",
              "sort": "desc"
            }
          },
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total[1h])) * 3600",
              "legendFormat": "Transações Processadas/hora",
              "range": true,
              "refId": "A"
            },
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(ml_predictions_total{result=\"fraude\"}[1h])) * 3600",
              "legendFormat": "Fraudes Detectadas/hora",
              "range": true,
              "refId": "B"
            }
          ],
          "title": "📊 Volume de Transações e Detecções por Hora",
          "type": "timeseries"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "from": 99.9,
                    "result": {
                      "color": "green",
                      "index": 0,
                      "text": "Excelente"
                    },
                    "to": 100
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 99.5,
                    "result": {
                      "color": "yellow",
                      "index": 1,
                      "text": "Adequado"
                    },
                    "to": 99.9
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0,
                    "result": {
                      "color": "red",
                      "index": 2,
                      "text": "Crítico"
                    },
                    "to": 99.5
                  },
                  "type": "range"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 99.5
                  },
                  {
                    "color": "green",
                    "value": 99.9
                  }
                ]
              },
              "unit": "percent"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 8,
            "x": 16,
            "y": 10
          },
          "id": 7,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "system_availability_percent",
              "legendFormat": "Disponibilidade do Sistema",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "⚡ Disponibilidade do Sistema (%)",
          "type": "gauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 18
          },
          "id": 8,
          "panels": [],
          "title": "🎯 Eficácia e Qualidade do Sistema",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.85
                  },
                  {
                    "color": "green",
                    "value": 0.95
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 6,
            "x": 0,
            "y": 19
          },
          "id": 9,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_precision{model_version=\"1.0\", model_type=\"xgboost\"}",
              "legendFormat": "Precision",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🎯 Precisão do Modelo",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.8
                  },
                  {
                    "color": "green",
                    "value": 0.9
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 6,
            "x": 6,
            "y": 19
          },
          "id": 10,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "model_recall{model_version=\"1.0\", model_type=\"xgboost\"}",
              "legendFormat": "Recall",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🔍 Recall do Modelo",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.001
                  },
                  {
                    "color": "red",
                    "value": 0.01
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 6,
            "x": 12,
            "y": 19
          },
          "id": 11,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(rate(false_positive_alerts_total[1h])) / sum(rate(ml_predictions_total[1h]))",
              "legendFormat": "Taxa Falsos Positivos",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "⚠️ Taxa de Falsos Positivos",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "from": 4.5,
                    "result": {
                      "color": "green",
                      "index": 0,
                      "text": "Excelente"
                    },
                    "to": 5
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 3.5,
                    "result": {
                      "color": "yellow",
                      "index": 1,
                      "text": "Bom"
                    },
                    "to": 4.5
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0,
                    "result": {
                      "color": "red",
                      "index": 2,
                      "text": "Precisa Melhorar"
                    },
                    "to": 3.5
                  },
                  "type": "range"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 3.5
                  },
                  {
                    "color": "green",
                    "value": 4.5
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 6,
            "w": 6,
            "x": 18,
            "y": 19
          },
          "id": 12,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "customer_satisfaction_score",
              "legendFormat": "Satisfação do Cliente",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "😊 Satisfação do Cliente (1-5)",
          "type": "gauge"
        },
        {
          "collapsed": false,
          "gridPos": {
            "h": 1,
            "w": 24,
            "x": 0,
            "y": 25
          },
          "id": 13,
          "panels": [],
          "title": "🏛️ Status de Conformidade e Governança",
          "type": "row"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [
                {
                  "options": {
                    "from": 0.95,
                    "result": {
                      "color": "green",
                      "index": 0,
                      "text": "Conforme"
                    },
                    "to": 1
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0.85,
                    "result": {
                      "color": "yellow",
                      "index": 1,
                      "text": "Atenção"
                    },
                    "to": 0.95
                  },
                  "type": "range"
                },
                {
                  "options": {
                    "from": 0,
                    "result": {
                      "color": "red",
                      "index": 2,
                      "text": "Não Conforme"
                    },
                    "to": 0.85
                  },
                  "type": "range"
                }
              ],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "red",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 0.85
                  },
                  {
                    "color": "green",
                    "value": 0.95
                  }
                ]
              },
              "unit": "percentunit"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 0,
            "y": 26
          },
          "id": 14,
          "options": {
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "showThresholdLabels": false,
            "showThresholdMarkers": true
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "bcb_403_compliance_score{article=\"overall\"}",
              "legendFormat": "Conformidade BCB 403",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "📋 Status de Conformidade BCB 403",
          "type": "gauge"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "prometheus"
          },
          "fieldConfig": {
            "defaults": {
              "color": {
                "mode": "thresholds"
              },
              "mappings": [],
              "thresholds": {
                "mode": "absolute",
                "steps": [
                  {
                    "color": "green",
                    "value": null
                  },
                  {
                    "color": "yellow",
                    "value": 1
                  },
                  {
                    "color": "red",
                    "value": 5
                  }
                ]
              },
              "unit": "short"
            },
            "overrides": []
          },
          "gridPos": {
            "h": 8,
            "w": 12,
            "x": 12,
            "y": 26
          },
          "id": 15,
          "options": {
            "colorMode": "value",
            "graphMode": "area",
            "justifyMode": "auto",
            "orientation": "auto",
            "reduceOptions": {
              "calcs": [
                "lastNotNull"
              ],
              "fields": "",
              "values": false
            },
            "textMode": "auto"
          },
          "pluginVersion": "9.3.1",
          "targets": [
            {
              "datasource": {
                "type": "prometheus",
                "uid": "prometheus"
              },
              "editorMode": "code",
              "expr": "sum(increase(regulatory_alerts_total{severity=\"critical\"}[7d]))",
              "legendFormat": "Alertas Críticos (7 dias)",
              "range": true,
              "refId": "A"
            }
          ],
          "title": "🚨 Alertas Regulatórios Críticos (7 dias)",
          "type": "stat"
        }
      ],
      "refresh": "1m",
      "schemaVersion": 37,
      "style": "dark",
      "tags": [
        "mlsecops",
        "executive",
        "kpis",
        "business"
      ],
      "templating": {
        "list": []
      },
      "time": {
        "from": "now-7d",
        "to": "now"
      },
      "timepicker": {},
      "timezone": "",
      "title": "Executive Dashboard - MLSecOps",
      "uid": "executive",
      "version": 1,
      "weekStart": ""
    })

    # =========================================================================
    # CONFIGURAÇÃO FINAL - Provisionamento dos Dashboards
    # =========================================================================
  }
}

# Configuração do provisionamento de dashboards para o Grafana
resource "kubernetes_config_map" "grafana_dashboard_provisioning" {
  metadata {
    name      = "grafana-dashboard-provisioning"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "dashboards.yaml" = <<EOF
apiVersion: 1
providers:
- name: 'mlsecops-stakeholder-dashboards'
  orgId: 1
  folder: 'MLSecOps - Dashboards Segmentados'
  type: file
  disableDeletion: false
  updateIntervalSeconds: 10
  allowUiUpdates: true
  options:
    path: /var/lib/grafana/dashboards
EOF
  }
}