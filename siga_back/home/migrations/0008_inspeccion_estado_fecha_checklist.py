from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('home', '0007_categoriaembalaje_estadoopeaduanera_tipoembalaje'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                ALTER TABLE inspeccion
                    ADD COLUMN estado VARCHAR(50) NOT NULL DEFAULT 'En revisión',
                    ADD COLUMN fecha_aprobacion DATE NULL,
                    ADD COLUMN checklist_data TEXT NULL;

                UPDATE inspeccion SET estado = 'Con incidencias'
                    WHERE resultado = 'Con incidencias';
                UPDATE inspeccion SET estado = 'En despacho', fecha_aprobacion = CURDATE()
                    WHERE resultado = 'Aprobado';
                UPDATE inspeccion SET estado = 'Segunda inspección'
                    WHERE resultado LIKE 'Segunda%';
            """,
            reverse_sql="""
                ALTER TABLE inspeccion
                    DROP COLUMN estado,
                    DROP COLUMN fecha_aprobacion,
                    DROP COLUMN checklist_data;
            """,
        ),
    ]
