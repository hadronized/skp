/**
 * Author: Dimitri 'skp' Sabadie <dimitri.sabadie@gmail.com>
 * License: GPLv3
 */
 
module skp.event;

/*********************
 * Event Handler mixin.
 *
 * An event handler is an object that handles signals (events)
 * and triggers objects that want to know when an event occurs.
 *
 * You can turn a symbol (class/struct) to manage events using
 * that mixin. For instance, you have a class that implements a
 * a method foo() in which you ask the user to type something.
 * When you finally get what he wrote, you want to notify all
 * attached objects the text he entered. It's quite simple: you
 * make your class an event handler, you create a listener
 * interface that define a method on_input(), then after you
 * got the user text, just call the trigger function to
 * notify all attached objects that the user entered the given
 * text.
 *
 * Params:
 *     L_ = type of listener
 */
mixin template MTEventHandler(L_) {
    private L_[] _listeners;

    /*********************
     * Attach an object to notify events.
     *
     * The object to attach must implement the interface of the
     * event handler.
     *
     * After a call to that method, the event Handler will
     * notify that object on an event.
     *
     * Params:
     *     l = object to attach
     */
    void add_listener(L_ l) {
        _listeners ~= l;
    }

    /*********************
     * Trigger all attached objects on event.
     *
     * That method is used to notify all attached objects on
     * an event.
     *
     * Params:
     *     E_ = the name of the event (listener's method to call)
     *     a = arguments to pass to the listener's method
     */
    void trigger(string E_, Args_...)(Args_ a) {
        mixin("
                foreach (l; _listeners) {
                    if (!l." ~ E_ ~ "(a))
                        break;
                }
        ");
    }
}
