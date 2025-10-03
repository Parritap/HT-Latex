# 🧩 Ampliación de la Infraestructura HTCondor para el GRID

## 📖 Descripción

Este proyecto corresponde a una **tesis de pregrado** cuyo propósito es **proponer un universo para la ampliación de la infraestructura HTCondor del Grupo de Investigación en Redes, Información y Distribución (GRID)** de la **Universidad del Quindío**.

La propuesta busca fortalecer las capacidades de computación distribuida del GRID mediante la incorporación de un nuevo universo HTCondor, contribuyendo al cumplimiento de sus objetivos misionales de **docencia, investigación y extensión** y democratizando el acceso a recursos de computación de alta productividad (HTC) para la comunidad académica.

---

## 🎯 Objetivos

### Objetivo general
Proponer un Universo para la ampliación de la infraestructura HTCondor del grupo de investigación GRID de la Universidad del Quindío.

### Objetivos específicos
- Determinar necesidades, oportunidades y/o problemas (NPO) con relación a la infraestructura HTCondor del GRID.
- Identificar, analizar y caracterizar universos HTCondor y seleccionar un universo para la infraestructura del GRID.
- Especificar el diseño arquitectónico requerido para la implementación del universo HTCondor seleccionado.
- Implementar un prototipo funcional del universo HTCondor seleccionado según el diseño especificado.
- Validar la implementación del universo HTCondor seleccionado según las NPO del GRID.

---

## 📚 Marco Conceptual

### Computación Distribuida
Paradigma computacional que involucra dos o más computadoras conectadas en red que trabajan colaborativamente para compartir y ejecutar tareas computacionales, distribuyendo las cargas de trabajo a través de múltiples nodos.

### High Throughput Computing (HTC)
Categoría específica de paralelismo computacional caracterizada por ejecutar múltiples copias idénticas de una aplicación de manera simultánea, enfocándose en la productividad a largo plazo más que en el rendimiento instantáneo.

### HTCondor
Sistema especializado de gestión de cargas de trabajo diseñado para trabajos computacionalmente intensivos, que proporciona mecanismos de encolado, política de programación, monitoreo de recursos y gestión distribuida mediante el paradigma de matchmaking y ClassAds.

### Universo HTCondor
Parámetro de ejecución fundamental que define el entorno operativo y el mecanismo de ejecución específico para una tarea enviada al clúster. Determina aspectos críticos como gestión de procesos, manejo de archivos, capacidad de checkpointing y el tipo de aplicación que puede ejecutarse.

---

## 🧪 Metodología

La metodología se desarrolló en fases sucesivas, siguiendo un enfoque sistemático:

1. **Caracterización del GRID**: Análisis de stakeholders, infraestructura actual y necesidades específicas.
2. **Identificación y análisis de universos**: Caracterización de universos HTCondor disponibles.
3. **Selección de universo**: Evaluación y selección del universo más adecuado para las necesidades del GRID.
4. **Diseño arquitectónico**: Especificación del diseño requerido para la implementación.
5. **Implementación del prototipo**: Desarrollo de un producto mínimo viable (PMV).
6. **Validación**: Pruebas técnicas y retroalimentación de usuarios del GRID.

---

## ⚙️ Universos HTCondor Evaluados

Los universos HTCondor contemplados en la investigación incluyen:

- **Vanilla**: Universo por defecto para ejecución de propósito general
- **Container**: Ejecución de aplicaciones en contenedores OCI
- **Docker**: Ejecución específica de contenedores Docker
- **Java**: Optimizado para aplicaciones Java
- **VM**: Ejecución en máquinas virtuales
- **Parallel**: Para trabajos paralelos MPI
- **Grid**: Integración con recursos de grid computing
- **Scheduler**: Para trabajos de programación específica
- **Local**: Ejecución en recursos locales

---

## 🏗️ Infraestructura Actual del GRID

### Clúster de Raspberry Pi
- **9 torres** de equipos Raspberry Pi (Torre 1-9)
- **7 equipos por torre** (excepto Torre 1 con 2 equipos)
- **Torre 1**: Nodo maestro y nodo de envío
- **Torres 2-8**: Nodos ejecutores
- **Conectividad**: Switch Cisco SF100D-08 por torre
- **Switch principal**: Cisco SG200-26

### Configuración Actual
- **Universo implementado**: Vanilla únicamente
- **Orientación**: Ejecución no especializada de programas
- **Casos de uso**: Scripts de Shell y aplicaciones de propósito general

---

## 🚀 Impacto Esperado

### Para el GRID
- Consolidación de infraestructura de computación distribuida más amplia y capaz
- Incremento en competitividad en el ámbito de HTC
- Fortalecimiento como referente regional en tecnologías de computación distribuida
- Potenciación de colaboraciones interuniversitarias

### Para la Comunidad Académica
- Democratización del acceso a recursos de computación distribuida
- Apoyo a disciplinas que requieren procesamiento intensivo (bioinformática, big data, IA)
- Oportunidades formativas en HTC para estudiantes
- Fortalecimiento de capacidades investigativas institucionales

### Casos de Uso Potenciales
- Simulaciones científicas y modelado matemático
- Procesamiento de datos masivos
- Análisis bioinformático y genómico
- Aprendizaje automático distribuido
- Renderización y procesamiento de imágenes
- Investigación en computación de alto rendimiento

---

## 📊 Beneficios de la Ampliación

- **Versatilidad**: Múltiples ambientes de ejecución especializados
- **Eficiencia**: Optimización según el tipo de carga de trabajo
- **Escalabilidad**: Capacidad de crecimiento según demanda
- **Accesibilidad**: Servicios disponibles 24/7 para la comunidad académica
- **Formación**: Plataforma práctica para enseñanza de HTC
- **Investigación**: Soporte a proyectos de mayor envergadura computacional
