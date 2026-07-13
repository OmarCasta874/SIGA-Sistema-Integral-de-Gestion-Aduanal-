(function () {
    function normalizarTexto(texto) {
        return texto
            .trim()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .toLowerCase();
    }
    function extraerValorNumerico(texto) {
        const t = texto.trim();
        const esNegativo = /^-/.test(t);
        const soloDigitos = t.replace(/[^0-9.,]/g, '').replace(/,/g, '');
        if (soloDigitos === '') return null;
        const numero = parseFloat(soloDigitos);
        if (isNaN(numero)) return null;
        return esNegativo ? -numero : numero;
    }
    function extraerValorFecha(texto) {
        const fecha = Date.parse(texto.trim());
        return isNaN(fecha) ? null : fecha;
    }
    function obtenerValorCelda(fila, columna) {
        const celda = fila.children[columna];
        return celda ? celda.textContent.trim() : '';
    }
    function esFilaVacia(fila) {
        return fila.children.length === 1 && fila.children[0].hasAttribute('colspan');
    }
    function ordenarFilas(filas, columna, modo) {
        const todasNumericas = filas.every(f => extraerValorNumerico(obtenerValorCelda(f, columna)) !== null);
        const todasFechas = !todasNumericas && filas.every(f => extraerValorFecha(obtenerValorCelda(f, columna)) !== null);

        filas.sort((a, b) => {
            const textoA = obtenerValorCelda(a, columna);
            const textoB = obtenerValorCelda(b, columna);
            let comparacion;

            if (modo === 'alfabetico') {
                comparacion = normalizarTexto(textoA).localeCompare(normalizarTexto(textoB));
            } else if (todasNumericas) {
                comparacion = extraerValorNumerico(textoA) - extraerValorNumerico(textoB);
            } else if (todasFechas) {
                comparacion = extraerValorFecha(textoA) - extraerValorFecha(textoB);
            } else {
                comparacion = normalizarTexto(textoA).localeCompare(normalizarTexto(textoB));
            }

            return modo === 'descendente' ? comparacion * -1 : comparacion;
        });

        return filas;
    }
    function aplicarOrden(select) {
        if (!select.value) return;

        const opcion = select.options[select.selectedIndex];
        const modo = opcion.dataset.modo || select.value;
        const columna = opcion.dataset.columna !== undefined
            ? parseInt(opcion.dataset.columna, 10)
            : (parseInt(select.dataset.ordenadorColumna, 10) || 0);

        const targetId = select.dataset.ordenadorTarget;
        const tbody = document.getElementById(targetId);
        if (!tbody) return;

        const filas = Array.from(tbody.querySelectorAll('tr'));
        const filasVacias = filas.filter(esFilaVacia);
        const filasDatos = filas.filter(f => !esFilaVacia(f));

        if (filasDatos.length === 0) return;

        const filasOrdenadas = ordenarFilas(filasDatos, columna, modo);

        const fragmento = document.createDocumentFragment();
        filasOrdenadas.forEach(f => fragmento.appendChild(f));
        filasVacias.forEach(f => fragmento.appendChild(f));
        tbody.appendChild(fragmento);
    }
    function iniciar() {
        document.querySelectorAll('[data-ordenador]').forEach(select => {
            select.addEventListener('change', () => aplicarOrden(select));
        });
    }
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', iniciar);
    } else {
        iniciar();
    }
})();