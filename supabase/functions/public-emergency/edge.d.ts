/** Minimal types so VS Code / tsserver understand this Deno Edge file without the Deno extension. */
declare const Deno: {
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
  env: { get(key: string): string | undefined };
};

declare module "https://esm.sh/@supabase/supabase-js@2.49.1" {
  export function createClient(
    supabaseUrl: string,
    supabaseKey: string,
  ): {
    rpc(
      fn: string,
      args?: Record<string, unknown>,
    ): Promise<{ data: unknown; error: { message?: string } | null }>;
    from(table: string): {
      insert(row: Record<string, unknown>): Promise<{ error: { message?: string } | null }>;
    };
  };
}
