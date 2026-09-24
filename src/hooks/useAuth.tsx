import { createContext, useContext, useEffect, useState, useCallback, type ReactNode } from "react";
import { supabase } from "@/integrations/supabase/client";

interface AuthCtx {
  user: any | null; // This will now be your profile data
  loading: boolean;
  signOut: () => void;
  refreshUser: () => Promise<void>;
}

const Ctx = createContext<AuthCtx>({
  user: null,
  loading: true,
  signOut: () => {},
  refreshUser: async () => {},
});

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<any | null>(null);
  const [loading, setLoading] = useState(true);

  const checkUser = useCallback(async () => {
    try {
      const localId = localStorage.getItem('bonded_user_id');
      
      if (localId) {
        // Fetch the actual profile data using the ID we stored
        const { data, error } = await (supabase.from('profiles') as any)
          .select('*')
          .eq('id', localId)
          .maybeSingle();

        if (data && !error) {
          setUser(data);
        } else {
          // If ID exists but profile doesn't, clear it
          localStorage.removeItem('bonded_user_id');
          setUser(null);
        }
      } else {
        setUser(null);
      }
    } catch (err) {
      console.error("Auth check failed", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    checkUser();
  }, [checkUser]);

  const signOut = () => {
    localStorage.removeItem('bonded_user_id');
    setUser(null);
    window.location.href = "/auth"; // Force refresh to clear state
  };

  const refreshUser = useCallback(async () => {
    await checkUser();
  }, [checkUser]);

  return (
    <Ctx.Provider value={{ user, loading, signOut, refreshUser }}>
      {children}
    </Ctx.Provider>
  );
};

export const useAuth = () => useContext(Ctx);