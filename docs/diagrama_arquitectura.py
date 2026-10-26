"""Genera docs/arquitectura_aws.png: diagrama de alto nivel de la arquitectura en AWS.

Uso: python docs/diagrama_arquitectura.py
"""
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

SALIDA = Path(__file__).with_name("arquitectura_aws.png")

TINTA = "#0b0b0b"
TINTA_2 = "#52514e"
FONDO = "#fcfcfb"
BORDE = "#c3c2b7"
AZUL = "#2a78d6"
NARANJA = "#eb6834"
GRUPOS = {
    "datos": "#e6f0fc",
    "ml": "#fdeee7",
    "consumo": "#e4f5ee",
    "orquestacion": "#f0efec",
    "operacion": "#f0efec",
}

fig, ax = plt.subplots(figsize=(17, 9.6))
fig.patch.set_facecolor(FONDO)
ax.set_xlim(0, 170)
ax.set_ylim(0, 96)
ax.axis("off")


def grupo(x, y, w, h, titulo, color):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0,rounding_size=1.5",
                                facecolor=color, edgecolor="none", zorder=0))
    ax.text(x + 1.5, y + h - 1.6, titulo, fontsize=10.5, fontweight="bold",
            color=TINTA_2, va="top", zorder=1)


def caja(x, y, w, h, titulo, detalle="", acento=AZUL, discontinua=False):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0,rounding_size=1",
                                facecolor="white", edgecolor=BORDE, linewidth=1.2,
                                linestyle="--" if discontinua else "-", zorder=2))
    ax.add_patch(FancyBboxPatch((x, y + h - 0.9), w, 0.9, boxstyle="square,pad=0",
                                facecolor=acento, edgecolor="none", zorder=3))
    ax.text(x + w / 2, y + h - 2.6, titulo, ha="center", va="top", fontsize=10,
            fontweight="bold", color=TINTA, zorder=4)
    if detalle:
        lineas_titulo = titulo.count("\n") + 1
        ax.text(x + w / 2, y + h - 3.4 - 2.3 * lineas_titulo, detalle, ha="center", va="top", fontsize=8.6,
                color=TINTA_2, linespacing=1.35, zorder=4)
    return {"x": x, "y": y, "w": w, "h": h}


def borde(c, lado):
    x, y, w, h = c["x"], c["y"], c["w"], c["h"]
    return {"izq": (x, y + h / 2), "der": (x + w, y + h / 2),
            "arriba": (x + w / 2, y + h), "abajo": (x + w / 2, y)}[lado]


def flecha(origen, destino, color=TINTA_2, estilo="-", rad=0.0, etiqueta=None, pos=0.5, dx=0, dy=1.2):
    ax.add_patch(FancyArrowPatch(origen, destino, arrowstyle="-|>", mutation_scale=13,
                                 color=color, linewidth=1.4, linestyle=estilo,
                                 connectionstyle=f"arc3,rad={rad}", zorder=1.5))
    if etiqueta:
        mx = origen[0] + (destino[0] - origen[0]) * pos + dx
        my = origen[1] + (destino[1] - origen[1]) * pos + dy
        ax.text(mx, my, etiqueta, ha="center", va="bottom", fontsize=8, color=TINTA_2,
                zorder=4, bbox={"facecolor": FONDO, "edgecolor": "none", "pad": 0.6})


def paso(x, y, n):
    ax.scatter([x], [y], s=260, color=TINTA, zorder=5)
    ax.text(x, y, str(n), ha="center", va="center", fontsize=9, color="white",
            fontweight="bold", zorder=6)


# Titulo
ax.text(1, 94.5, "Arquitectura propuesta en AWS: recompra a 60 días", fontsize=15,
        fontweight="bold", color=TINTA, va="top")
ax.text(1, 90.6, "Ejecución diaria de predicciones, reentrenamiento mensual y monitoreo continuo",
        fontsize=10.5, color=TINTA_2, va="top")

# Orquestacion
grupo(24, 70, 145, 17.5, "Orquestación", GRUPOS["orquestacion"])
eventbridge = caja(26, 71.5, 35, 9.5, "Amazon EventBridge Scheduler",
                   "diario 06:00  |  mensual día 1", acento=TINTA_2)
stepf = caja(68, 71.5, 98, 9.5, "AWS Step Functions",
             "transformar → validar datos → [mensual: reentrenar → control de calidad → aprobar] → predecir → monitorear",
             acento=TINTA_2)
flecha(borde(eventbridge, "der"), borde(stepf, "izq"))

# Datos
grupo(1, 28, 72, 39, "Datos y transformación", GRUPOS["datos"])
s3_raw = caja(3, 37, 20, 24, "Amazon S3\nraw/",
              "orders, order_items,\nusers, products,\nevents\n\nCSV/Parquet por\nfecha de llegada")
athena = caja(26, 37, 24, 24, "Amazon Athena\n+ Glue Data Catalog",
              "SQL de las\nsecciones 1–4\n→ customer_model\n\ncontroles de calidad\n(SQL + validaciones\nPython)")
s3_cur = caja(53, 37, 18, 24, "Amazon S3\ncurated/",
              "customer_model\n(Parquet)\n\npartición\nfecha_corte=…")
flecha(borde(s3_raw, "der"), borde(athena, "izq"))
flecha(borde(athena, "der"), borde(s3_cur, "izq"))
paso(3, 61, 1)
paso(26, 61, 2)

# ML
grupo(77, 28, 46, 39, "Modelo (Amazon SageMaker)", GRUPOS["ml"])
training = caja(80, 50, 40, 11, "Training Job  ·  mensual",
                "reentrena con clientes etiquetados\ny compara con la regla de referencia", acento=NARANJA)
registry = caja(80, 39.5, 40, 8.5, "Model Registry",
                "versión · métricas · commit · aprobación", acento=NARANJA)
processing = caja(80, 29.5, 40, 8, "Processing Job  ·  diario",
                  "puntúa clientes con ventana abierta", acento=NARANJA)
flecha(borde(s3_cur, "der"), (80, 55.5))
flecha(borde(s3_cur, "der"), (80, 33.5))
flecha(borde(training, "abajo"), borde(registry, "arriba"))
flecha(borde(registry, "abajo"), borde(processing, "arriba"))
ax.text(101.5, 38.4, "modelo aprobado", va="center", fontsize=8, color=TINTA_2, zorder=4)
paso(80, 61, 3)
paso(80, 37.25, 4)

# Consumo
grupo(127, 28, 42, 39, "Predicciones y consumo", GRUPOS["consumo"])
s3_pred = caja(129, 40, 17, 21, "Amazon S3\npredictions/",
               "fecha_corte=…/\n\nsobrescritura\nidempotente", acento="#1baf7a")
quicksight = caja(150, 48, 17, 13, "Athena +\nQuickSight", "dashboard de\nnegocio", acento="#1baf7a")
crm = caja(150, 31, 17, 13, "CRM /\nmarketing", "campaña al\n30% priorizado", acento="#1baf7a")
flecha(borde(processing, "der"), borde(s3_pred, "izq"), rad=0.15)
flecha(borde(s3_pred, "der"), borde(quicksight, "izq"))
flecha(borde(s3_pred, "der"), borde(crm, "izq"))
paso(129, 61, 5)

# Orquestacion -> pasos
for destino in [(38, 61), (112, 61)]:
    flecha((destino[0], 71.5), destino, color=BORDE, estilo="--")

# Operacion: monitoreo y CI/CD
grupo(1, 1, 80, 25, "Monitoreo", GRUPOS["operacion"])
cw = caja(3, 2.5, 38, 18, "Amazon CloudWatch",
          "logs y métricas de cada ejecución\ncalidad de datos: volumen, nulos, tasa\nmodelo: deriva de variables y predicciones;\ndesempeño real a 60 días vs. la regla",
          acento=TINTA_2)
sns = caja(45, 6, 16, 12, "Amazon SNS", "alertas por\nemail o Slack", acento=TINTA_2)
flecha(borde(cw, "der"), borde(sns, "izq"))
paso(3, 20.5, 6)
ax.text(63.5, 12, "Si falla un control,\nStep Functions se\ndetiene y avisa", fontsize=8.2,
        color=TINTA_2, va="center", ha="left")

grupo(85, 1, 84, 25, "Versionamiento y despliegue (CI/CD)", GRUPOS["operacion"])
github = caja(88, 3, 22, 17.5, "GitHub", "SQL, código Python,\nnotebook, infraestructura\ncomo código, tests",
              acento=TINTA)
actions = caja(116, 3, 22, 17.5, "GitHub Actions", "tests y validaciones\nen cada pull request;\nbuild al fusionar a main",
               acento=TINTA)
deploy = caja(144, 3, 23, 17.5, "Amazon ECR\n+ AWS CDK", "imagen del contenedor\ny despliegue de\nStep Functions y jobs",
              acento=TINTA)
flecha(borde(github, "der"), borde(actions, "izq"))
flecha(borde(actions, "der"), borde(deploy, "izq"))
paso(88, 20.5, 7)

plt.savefig(SALIDA, dpi=150, bbox_inches="tight", facecolor=FONDO)
print("Diagrama guardado en", SALIDA)
