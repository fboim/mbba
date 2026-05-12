DROP POLICY IF EXISTS "jenjang_select" ON public.jenjang;
DROP POLICY IF EXISTS "jenjang_admin_all" ON public.jenjang;
DROP POLICY IF EXISTS "kitab_select" ON public.kitab;
DROP POLICY IF EXISTS "kitab_admin_all" ON public.kitab;
CREATE POLICY "anon_read_jenjang" ON public.jenjang FOR SELECT USING (true);
CREATE POLICY "anon_read_kitab" ON public.kitab FOR SELECT USING (true);
CREATE POLICY "admin_write_jenjang" ON public.jenjang FOR INSERT WITH CHECK (get_user_role() IN ('admin', 'teacher'));
CREATE POLICY "admin_write_kitab" ON public.kitab FOR INSERT WITH CHECK (get_user_role() IN ('admin', 'teacher'));
CREATE POLICY "admin_update_jenjang" ON public.jenjang FOR UPDATE USING (get_user_role() IN ('admin', 'teacher'));
CREATE POLICY "admin_update_kitab" ON public.kitab FOR UPDATE USING (get_user_role() IN ('admin', 'teacher'));

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
DECLARE
  claims text;
BEGIN
  claims := current_setting('request.jwt.claims', true);
  IF claims IS NULL THEN RETURN 'guest'; END IF;
  RETURN COALESCE(
    claims::jsonb->'user_metadata'->>'role',
    claims::jsonb->>'role',
    'guest'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
