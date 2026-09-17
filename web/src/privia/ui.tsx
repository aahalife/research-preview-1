import type { ReactNode, ComponentProps } from "react";
import { ArrowUpRight, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { cn } from "@/lib/utils";

export function RumiMark({ busy = false, className }: { busy?: boolean; className?: string }) {
  return <span aria-hidden="true" className={cn("relative inline-grid h-9 w-9 shrink-0 place-items-center", busy && "motion-safe:animate-pulse", className)}><span className="absolute inset-0 rounded-full border border-current opacity-25" /><span className="absolute inset-[5px] rounded-full border border-current opacity-45" /><span className="absolute inset-[10px] rounded-full border border-current opacity-75" /><span className="h-1.5 w-1.5 rounded-full bg-current" /></span>;
}
export function Card({ children, className }: { children: ReactNode; className?: string }) { return <section className={cn("rounded-[26px] border border-white/90 bg-[#FFFEFB] p-5 shadow-[0_8px_28px_-20px_#16483d55]", className)}>{children}</section>; }
export function Action({ children, className, secondary = false, ...props }: ComponentProps<typeof Button> & { secondary?: boolean }) {
  return <Button {...props} className={cn("min-h-11 h-auto whitespace-normal rounded-2xl px-5 py-3 font-medium transition-transform active:scale-[0.98]", secondary ? "border border-[#00211A]/15 bg-white text-[#00211A] hover:bg-[#edf7f2]" : "bg-[#00211A] text-white hover:bg-[#164a3d]", className)}>{children}</Button>;
}
export function Row({ title, detail, icon, onClick }: { title: string; detail?: string; icon?: ReactNode; onClick: () => void }) {
  return <button onClick={onClick} className="flex min-h-16 w-full items-center gap-3 py-3 text-left"><span className="text-[#29705d]">{icon}</span><span className="min-w-0 flex-1"><span className="block font-medium">{title}</span>{detail && <span className="mt-1 block text-[13px] leading-relaxed text-[#53685f]">{detail}</span>}</span><ChevronRight size={18} className="shrink-0 text-[#53685f]" /></button>;
}
export function Eyebrow({ children }: { children: ReactNode }) { return <p className="text-[11px] font-semibold uppercase tracking-[0.14em] text-[#526d61]">{children}</p>; }
export function Title({ children }: { children: ReactNode }) { return <h1 className="font-fields text-[34px] leading-[1.12] tracking-[-0.03em]">{children}</h1>; }
export function Sheet({ open, onClose, title, description, children, wide = false }: { open: boolean; onClose: () => void; title: string; description?: string; children: ReactNode; wide?: boolean }) {
  return <Dialog open={open} onOpenChange={v => { if (!v) onClose(); }}><DialogContent className={cn("privia flex max-h-[92dvh] w-[calc(100%-24px)] flex-col overflow-hidden rounded-[28px] border-white bg-[#f8fbf6] p-6 text-[#00211A] sm:rounded-[28px] [&>button:last-child]:min-h-11 [&>button:last-child]:min-w-11 [&>button:last-child]:right-1 [&>button:last-child]:top-1 [&>button:last-child]:grid [&>button:last-child]:place-items-center", wide ? "max-w-2xl" : "max-w-[460px]")}><DialogTitle className="font-fields pr-9 text-[29px] font-normal tracking-tight">{title}</DialogTitle><DialogDescription className="text-[13px] leading-relaxed text-[#53685f]">{description ?? "Synthetic demonstration. Changes stay in this browser."}</DialogDescription><div className="min-h-0 overflow-y-auto space-y-5 pb-1 pr-1">{children}</div></DialogContent></Dialog>;
}
export function Note({ children }: { children: ReactNode }) { return <p className="text-[13px] leading-relaxed text-[#53685f]">{children}</p>; }
export function TextLink({ children, onClick }: { children: ReactNode; onClick: () => void }) { return <button onClick={onClick} className="inline-flex min-h-11 items-center gap-2 text-[14px] font-medium underline decoration-[#00211A]/20 underline-offset-4">{children}<ArrowUpRight size={15} /></button>; }
export const inputClass = "min-h-11 w-full rounded-xl border border-[#00211A]/15 bg-white px-3 py-3 text-[16px] text-[#00211A] outline-none focus:ring-2 focus:ring-[#287d66]";
