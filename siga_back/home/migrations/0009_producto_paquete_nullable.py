from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0008_inspeccion_estado_fecha_checklist'),
    ]

    operations = [
        # 1. Permitir NULL en la columna paquete de producto
        migrations.RunSQL(
            sql='ALTER TABLE producto MODIFY COLUMN paquete int(11) NULL',
            reverse_sql='ALTER TABLE producto MODIFY COLUMN paquete int(11) NOT NULL',
        ),
        # 2. Desvincular productos sobrantes: conservar solo los 3 primeros por paquete
        migrations.RunSQL(
            sql="""
                UPDATE producto
                INNER JOIN (
                    SELECT codigo
                    FROM (
                        SELECT codigo,
                               ROW_NUMBER() OVER (PARTITION BY paquete ORDER BY codigo) AS rn
                        FROM producto
                        WHERE paquete IS NOT NULL
                    ) AS ranked
                    WHERE rn > 3
                ) AS to_unlink ON producto.codigo = to_unlink.codigo
                SET producto.paquete = NULL
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
