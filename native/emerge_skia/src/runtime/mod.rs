pub(crate) mod tree_actor;
pub mod tree_update;

pub mod host_feedback;

pub(crate) mod backlight;
pub(crate) mod config;
pub(crate) mod lifecycle;
pub(crate) mod touch_wake;

/// Nice value of the threads that produce frames, the tree actor and the DRM presenter. WebKit and
/// the BEAM schedulers run at 0; when they keep more threads runnable than there are cores, a
/// frame thread at 0 waits several milliseconds per preemption.
#[cfg(target_os = "linux")]
const FRAME_THREAD_NICE: libc::c_int = -10;

/// Raises the calling thread to `FRAME_THREAD_NICE`. Without `CAP_SYS_NICE` the call fails and
/// the thread keeps its priority.
pub(crate) fn raise_frame_thread_priority() {
    #[cfg(target_os = "linux")]
    unsafe {
        let tid = libc::syscall(libc::SYS_gettid) as libc::id_t;
        libc::setpriority(libc::PRIO_PROCESS, tid, FRAME_THREAD_NICE);
    }
}
