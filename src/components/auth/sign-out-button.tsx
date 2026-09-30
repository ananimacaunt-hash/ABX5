import { LogOut } from "lucide-react";

import { signOutAction } from "@/app/(site)/auth/actions";
import { Button } from "@/components/ui/button";

export function SignOutButton() {
  return (
    <form action={signOutAction}>
      <Button type="submit" variant="ghost" className="min-h-9 gap-2 px-3 text-sm">
        <LogOut className="h-4 w-4" aria-hidden="true" />
        Sign out
      </Button>
    </form>
  );
}
