from django.db import migrations


class Migration(migrations.Migration):
    """
    Corrige el estado de operaciones aduaneras que ya tienen pago registrado
    pero cuyo campo estado_ope_aduanera no se actualizó en el seed:

      - Semáforo Verde + pago existente  → Completada (2)
      - Semáforo Rojo  + pago existente y estado "Pendiente de pago"
                                         → En revisión (5)
    """

    dependencies = [
        ('home', '0012_roles_usuarios_admin'),
    ]

    operations = [
        # Verde con pago → Completada
        migrations.RunSQL(
            sql="""
                UPDATE operacion_aduanera oa
                INNER JOIN pedimento p ON p.ope_aduanera = oa.ID_operacion
                INNER JOIN semaforo_fiscal sf ON p.semaforo = sf.ID
                SET oa.estado_ope_aduanera = 2
                WHERE sf.resultado LIKE '%Verde%'
                  AND EXISTS (
                      SELECT 1 FROM pago pg WHERE pg.pedimento = p.numero_pedimento
                  )
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
        # Rojo con pago y aún "Pendiente de pago" → En revisión
        migrations.RunSQL(
            sql="""
                UPDATE operacion_aduanera oa
                INNER JOIN pedimento p ON p.ope_aduanera = oa.ID_operacion
                INNER JOIN semaforo_fiscal sf ON p.semaforo = sf.ID
                SET oa.estado_ope_aduanera = 5
                WHERE sf.resultado NOT LIKE '%Verde%'
                  AND oa.estado_ope_aduanera = 4
                  AND EXISTS (
                      SELECT 1 FROM pago pg WHERE pg.pedimento = p.numero_pedimento
                  )
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
