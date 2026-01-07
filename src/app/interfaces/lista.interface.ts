export interface Lista {
  id?: number;
  titulo: string;
  descripcion?: string;
  fecha_creacion?: string;
}

export interface CrearListaRequest {
  titulo: string;
  descripcion?: string;
}

export interface CrearListaResponse {
  success: boolean;
  message: string;
  data: Lista;
}
